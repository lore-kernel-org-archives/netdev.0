From: robert@herjulf.net
Subject: Re: ixgbe question
Date: Mon, 23 Nov 2009 21:54:43 +0100
Message-ID: <19210.63123.814368.292600@gargle.gargle.HOWL>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	<2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
	<1258968980.2697.9.camel@ppwaskie-mobl2>
	<4B0A6218.9040303@gmail.com>
	<Pine.LNX.4.64.0911231500060.24347@ask.diku.dk>
	<4B0A9E4E.9010804@gmail.com>
	<19210.54486.353397.804028@gargle.gargle.HOWL>
	<4B0ABF6D.9000103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert@herjulf.net, Jesper Dangaard Brouer <hawk@diku.dk>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from klais.its.uu.se ([130.238.7.59]:38050 "EHLO klais.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784AbZKWSon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 13:44:43 -0500
In-Reply-To: <4B0ABF6D.9000103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:

 > slone_skb set to 1, this changes nothing but slows down pktgen (obviously)

 > All RX processing of 16 RX queues done by CPU 1 only.


 Well just pulled net-next-2.6 and ran with both 82598 and 82599 boards and 
 pkt load gets distributed among the cpu-cores. 


 Something mysterious or very obvious...
 
 You can even try the script it's a sort of Internet Link traffic emulation
 well you have to set up your routing.


 Cheers
					--ro

 


#! /bin/sh

#modprobe pktgen

function pgset() {
    local result

    echo $1 > $PGDEV

    result=`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" = "" ]; then
         cat $PGDEV | fgrep Result:
    fi
}

function pg() {
    echo inject > $PGDEV
    cat $PGDEV
}

# Config Start Here -----------------------------------------------------------

remove_all()
{
 # thread config
 PGDEV=/proc/net/pktgen/kpktgend_0
 pgset "rem_device_all" 

 PGDEV=/proc/net/pktgen/kpktgend_1
 pgset "rem_device_all" 

 PGDEV=/proc/net/pktgen/kpktgend_2
 pgset "rem_device_all" 

 PGDEV=/proc/net/pktgen/kpktgend_3
 pgset "rem_device_all" 

 PGDEV=/proc/net/pktgen/kpktgend_4
 pgset "rem_device_all" 

 PGDEV=/proc/net/pktgen/kpktgend_5
 pgset "rem_device_all" 

 PGDEV=/proc/net/pktgen/kpktgend_6
 pgset "rem_device_all" 

 PGDEV=/proc/net/pktgen/kpktgend_7
 pgset "rem_device_all" 
}

remove_all

 PGDEV=/proc/net/pktgen/kpktgend_0
 pgset "add_device eth2@0" 

 PGDEV=/proc/net/pktgen/kpktgend_1
 pgset "add_device eth2@1" 

 PGDEV=/proc/net/pktgen/kpktgend_2
 pgset "add_device eth2@2" 

 PGDEV=/proc/net/pktgen/kpktgend_3
 pgset "add_device eth2@3" 


# device config
#
# Sending a mix of pkt sizes of 64, 576 and 1500
#

CLONE_SKB="clone_skb 1"
PKT_SIZE="pkt_size 60"
COUNT="count 000000"
DELAY="delay 0000"
#MAC="00:21:28:08:40:EE"
#MAC="00:21:28:08:40:EF"
#MAC="00:1B:21:17:C1:CD"
MAC="00:14:4F:DA:8C:66"
#MAC="00:14:4F:6B:CD:E8"


PGDEV=/proc/net/pktgen/eth2@0
echo "Configuring $PGDEV"
pgset "$COUNT"
pgset "$CLONE_SKB"
pgset "pkt_size 1496"
pgset "$DELAY"
pgset "flag QUEUE_MAP_CPU"
pgset "flag IPDST_RND" 
pgset "flag FLOW_SEQ" 
pgset "dst_min 11.0.0.0" 
pgset "dst_max 11.255.255.255" 
pgset "flows 2048" 
pgset "flowlen 30" 
pgset  "dst_mac $MAC"

PGDEV=/proc/net/pktgen/eth2@1
echo "Configuring $PGDEV"
pgset "$COUNT"
pgset "$CLONE_SKB"
pgset "pkt_size 576"
pgset "$DELAY"
pgset "flag QUEUE_MAP_CPU"
pgset "flag IPDST_RND" 
pgset "flag FLOW_SEQ" 
pgset "dst_min 11.0.0.0" 
pgset "dst_max 11.255.255.255" 
pgset "flows 2048" 
pgset "flowlen 30" 
pgset  "dst_mac $MAC"

PGDEV=/proc/net/pktgen/eth2@2
echo "Configuring $PGDEV"
pgset "$COUNT"
pgset "$CLONE_SKB"
pgset "$DELAY"
pgset "pkt_size 60"
pgset "flag QUEUE_MAP_CPU"
pgset "flag IPDST_RND" 
pgset "flag FLOW_SEQ" 
pgset "dst_min 11.0.0.0" 
pgset "dst_max 11.255.255.255" 
pgset "flows 2048" 
pgset "flowlen 30" 
pgset  "dst_mac $MAC"

PGDEV=/proc/net/pktgen/eth2@3
echo "Configuring $PGDEV"
pgset "$COUNT"
pgset "$CLONE_SKB"
pgset "pkt_size 1496"
pgset "$DELAY"
pgset "flag QUEUE_MAP_CPU"
pgset "flag IPDST_RND" 
pgset "flag FLOW_SEQ" 
pgset "dst_min 11.0.0.0" 
pgset "dst_max 11.255.255.255" 
pgset "flows 2048" 
pgset "flowlen 30" 
pgset  "dst_mac $MAC"

# Time to run
PGDEV=/proc/net/pktgen/pgctrl

echo "Running... ctrl^C to stop"
pgset "start" 
echo "Done"

grep pps /proc/net/pktgen/*
