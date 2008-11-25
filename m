From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH] Naming interrupt vectors/script
Date: Tue, 25 Nov 2008 16:54:01 +0100
Message-ID: <18732.8089.317566.686309@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@robur.slu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:58325 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209AbYKYPyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 10:54:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



And a bash script attempt to set for RX/TX CPU affinity

Cheers.
				--ro


#! /bin/bash
# 
# Setting up irq affinity according to /proc/interrupts
# 2008-11-25 Robert Olsson
#
# > Dave Miller:
# (To get consistent naming in /proc/interrups)
# I would suggest that people use something like:
#	char buf[IFNAMSIZ+6];
#
#	sprintf(buf, "%s-%s-%d",
#	        netdev->name,
#		(RX_INTERRUPT ? "rx" : "tx"),
#		queue->index);
#
#  Assuming a device with two RX and TX queues.
#  This script will assign: 
#
#	eth0-rx-0  CPU0
#	eth0-rx-1  CPU1
#	eth0-tx-0  CPU0
#	eth0-tx-1  CPU1
#

set_affinity()
{
    MASK=$((1<<$VEC))
    echo $DEV mask=$MASK for /proc/irq/$IRQ/smp_affinity 
    echo $MASK > /proc/irq/$IRQ/smp_affinity 
}

#
# Set up the desired devices. 
# 

for DEV in eth0 eth1 eth2
do
  for DIR in  rx tx
  do
     for VEC in `seq 0 1 12`
     do
	IRQ=`cat /proc/interrupts | grep $DEV-$DIR-$VEC"$"  | cut  -d:  -f,1`
	if [ -n  "$IRQ" ]; then
	  set_affinity
	fi
     done
  done
done
