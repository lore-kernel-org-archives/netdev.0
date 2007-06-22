From: David Hollis <dhollis@davehollis.com>
Subject: Re: Linksys Gigabit USB2.0 adapter (asix) regression
Date: Fri, 22 Jun 2007 10:37:00 -0400
Message-ID: <1182523020.4938.20.camel@dhollis-lnx.sunera.com>
References: <467915D9.3030900@slagter.name>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Erik Slagter <erik@slagter.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:53009 "EHLO
	vms040pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755476AbXFVOhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 10:37:55 -0400
Received: from smtp.davehollis.com ([71.251.104.202])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JK1009WKKMKEBZ2@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 22 Jun 2007 09:37:32 -0500 (CDT)
In-reply-to: <467915D9.3030900@slagter.name>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-20 at 13:56 +0200, Erik Slagter wrote:

> To rule out the possibility of the nic being defective, I connected the
> USB nic to a windows computer. There it works, although the ethernet
> connection is a bit flaky (just like it seems...).
> 
> Then I did a diff on the respective kernel sources of 2.6.20.3 and
> 2.6.22-rc2 (asix.c and usbnet.c), I found a few changes, but they do not
> seem to be related to my problem.
> 
> I am the and of my repertoire here, can anyone please do some
> suggestions for further testing or even better, fix it ;-)

You wouldn't happen to know what PHY that device is using?  The AX88178
(Gigabit USB Ethernet) support in the driver currently only supports the
Marvell PHY, which is the only one I've actually encountered to-date.
If you can rebuild the driver from your kernel sources but with DEBUG
enabled (uncomment it at the top of asix.c)


You can build the driver out-of-tree by creating a Makefile with these
contents:

obj-m   += asix.o

EXTRA_CFLAGS += -DDEBUG

all:
        make -C /lib/modules/`uname -r`/build SUBDIRS=`pwd`

clean:
        make -C /lib/modules/`uname -r`/build SUBDIRS=`pwd` clean


(You'll also need to copy usbnet.h into that directory)


After you build the module, load it with insmod ./asix.ko, plug in your
device and send me the dmesg output.  I'm particularly interested in the
PHYID=0x12345678 line.  That will tell me what PHY chip is being used in
that device and if I need to add support for it.

-- 
David Hollis <dhollis@davehollis.com>

