From: Rick Jones <rick.jones2@hp.com>
Subject: Re: a maze of twisty stats, most different
Date: Thu, 28 Jun 2007 10:34:07 -0700
Message-ID: <4683F10F.6070007@hp.com>
References: <46829C48.6080005@hp.com> <4683ADFC.4020000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:34879 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756399AbXF1ReK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 13:34:10 -0400
In-Reply-To: <4683ADFC.4020000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook wrote:
> Rick Jones wrote:
> 
>> It seems that every driver, when providing support for ethtool -S 
>> functionality, has considerable lattitude when it comes to the stats 
>> provided.  Clearly this is very nice for the driver writer(s) as it 
>> allows them to provide whatever stats they feel are most "natural" for 
>> their NIC(s) and name them as they see fit.
> 
> 
> This is deliberate.  Ethtool operates at a very primitive level, and 
> generally does little or no translation between the hardware registers 
> and userspace.

Noted.

> 
>> However :)
>>
>>  From the standpoint of someone looking from the outside, say someone 
>> wanting to consume ethtool -S statistics, it seems to be a big jumble.
>>
>> Might there be a way to bring those two camps together?  Is there 
>> already, with the same wide availabilty of ethtool, and I've just not 
>> seen it?
> 
> 
> ifconfig comes to mind, for one.  What statistics are you looking for 
> exactly?

This would be my strawman - in terms of content not necessarily format, 
and not all the things would be applicable I'm sure.  Still, it covers 
the basics which are (IMO) sufficint for initial troubleshooting.

$ lanadmin -g mibstats 0

                       LAN INTERFACE STATUS DISPLAY
                        Thu, Jun 28,2007  10:24:02

PPA Number                      = 0
Description                     = lan0 HP PCI 10/100Base-TX Core 
[100BASE-TX,FD,AUTO,TT=1500]
Type (value)                    = ethernet-csmacd(6)
MTU Size                        = 1500
Speed                           = 100000000
Station Address                 = 0x1083cf5502
Administration Status (value)   = up(1)
Operation Status (value)        = up(1)
Last Change                     = 678
Inbound Octets                  = 2816678451
Inbound Unicast Packets         = 5557984
Inbound Non-Unicast Packets     = 6857814
Inbound Discards                = 0
Inbound Errors                  = 0
Inbound Unknown Protocols       = 798022
Outbound Octets                 = 1833385875
Outbound Unicast Packets        = 5744993
Outbound Non-Unicast Packets    = 3845
Outbound Discards               = 0
Outbound Errors                 = 0
Outbound Queue Length           = 0
Specific                        = 655367

Ethernet-like Statistics Group

Index                           = 1
Alignment Errors                = 0
FCS Errors                      = 0
Single Collision Frames         = 0
Multiple Collision Frames       = 0
Deferred Transmissions          = 0
Late Collisions                 = 0
Excessive Collisions            = 0
Internal MAC Transmit Errors    = 0
Carrier Sense Errors            = 0
Frames Too Long                 = 0
Internal MAC Receive Errors     = 0

What I'm thinking of might be as simple as a convention that the first N 
stats each driver provides are something akin to the above - consistent 
names and semantics for the stats, and then a driver/NIC-specific 
portion following

There is indeed pretty decent overlap with ifconfig output:

[root@hpcpc107 netperf2_work]# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:17:A4:AB:40:FB
           inet addr:16.89.84.107  Bcast:16.89.84.127  Mask:255.255.255.128
           inet6 addr: fe80::217:a4ff:feab:40fb/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:12448920 errors:0 dropped:0 overruns:0 frame:0
           TX packets:6075025 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:18505185007 (17.2 GiB)  TX bytes:2750351151 (2.5 GiB)
           Interrupt:55

The break-out of the stats is nice - "late collisions" in the lanadmin 
is quite helpful when looking for duplex mismatch.

I'm not sure if the "UP" and "RUNNING" are matched with administrative 
and operational state (what we want and what we have respectively).  The 
queue length in the lanadmin is the current queue length, not the limit. 
  Serves as a guesstimate as to the utilization of the NIC if one wants 
to abuse little's law and all that.

Mostly I'm looking for a bit broader set of link-level stats which would 
be reported consistenly regardless of NIC type.

rick jones
