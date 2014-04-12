From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: 802.1AD packets - Kernel changes ether type from 88A8 to 8100
 on all packets.
Date: Sun, 13 Apr 2014 01:20:36 +0900
Message-ID: <1397319636.1789.11.camel@localhost.localdomain>
References: <BLU184-W706F779E20884E4F486ED9D0540@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dennis Punjabi <linuxdev@icts.bz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:52093 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaDLQUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2014 12:20:42 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so6513529pdb.28
        for <netdev@vger.kernel.org>; Sat, 12 Apr 2014 09:20:42 -0700 (PDT)
In-Reply-To: <BLU184-W706F779E20884E4F486ED9D0540@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     1. On Fri, 2014-04-11 at 11:01 +0000, Dennis Punjabi wrote:
> Background:
> 1) I need to setup a Linux software bridge and ensure that packets coming in on one bridge port exit unchanged on another bridge port, like a normal HW bridge.
> 2) I need to use the new vlan filtering capability of the bridge. Good news of this feature is made in the kernel announcement of release 3.9 @ http://kernelnewbies.org/Linux_3.9
> 3) I need to test what presently happens to 802.1AD tagged packets when bridge vlan filtering is enabled because I also need support for Q-in-Q.
> 
> I am using a packet generator (Ostinato) and creating 802.1AD packets as follows:
> 
> (MAC_HDR)           (8021AD_HDR)   (8021Q HDR)  (PAYLOAD)
> 
> (DA | SA | TYPE)    (TCI | TPID)        (TCI | TPID)    (TEST PAYLOAD - ARP BCAST PACKET)
> 
> (DA | SA | 88A8)    (TCI | 8100)         (TCI | 0806)    (TEST PAYLOAD - ARP BCAST PACKET)
> 
> (hopefully the alignment is ok above, if not I apologize and hope its clear enough)
> 
> Even before setting up the the bridge, I want to ensure that packets are being received properly to my system.
> I do a tcpdump output for the port receiving the generated packets.
> 
> What I notice is that the 88A8 TPIC/ether type get changed to 8100.
> Ie, all packets with ether type 802.1AD get changed to 802.1Q type, ie 8100.
> I initially tested this on a 3.14 vanilla kernel.

Hi.

Though I'm not an expert with libpcap, I feel tcpdump sometimes shows a
wrong vlan protocol (if vlan_tci is used).

Maybe this topic has relevance?

packet: deliver VLAN TPID to userspace
http://marc.info/?l=linux-netdev&m=138728859001934&w=2
http://marc.info/?l=linux-netdev&m=138728859601935&w=2
http://marc.info/?l=linux-netdev&m=138728860101937&w=2
http://marc.info/?l=linux-netdev&m=138728860601939&w=2

Thanks,
Toshiaki Makita

> 
> I recompiled my 8139too.c driver and printed printk the packets in the driver before they are handed over to netif_receive_skb.
> Before being passed to the kernel networking stack the packet is as it is supposed to be, ie it has the correct 88A8 ether type.
> 
> I went ahead and tested this on kernel 3.12, 3.11, 3.10. I Saw the same result.
> 
> I also tested it on 3.9, 3.8 and 2.6 and these kernels did not change the 88A8 to 8100.
> 
> Is this intentional or a bug? Does this have something to do with the addition of the new feature (vlan: Add 802.1ad support) announced in kernel 3.10? http://kernelnewbies.org/Linux_3.10
> 
> I have been following the net-dev mailing lists and want to test the bridge 802.1AD filtering feature discussed here http://www.spinics.net/lists/linux-ethernet-bridging/msg05207.html but cannot do so if the bridge does not even get the 802.1AD tagged packets to begin with.
> 
> Assuming I don't want to use filtering and just want a simple bridge. The expected behaviour is that the bridge must not change my packet and should simply pass it along. Is my thinking correct?
> 
> Thanks for any help provided.
> 
> Dennis
>  		 	   		  --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
