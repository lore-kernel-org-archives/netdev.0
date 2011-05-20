From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP funny-ness when over-driving a 1Gbps link.
Date: Thu, 19 May 2011 17:46:17 -0700
Message-ID: <1305852377.8149.1133.camel@tardy>
References: <4DD59DF2.2070707@candelatech.com>
	 <20110519161827.2ba4b40e@nehalam> <4DD5A5CD.7040303@candelatech.com>
	 <4DD5AAFC.8070509@candelatech.com> <1305849940.8149.1122.camel@tardy>
	 <4DD5B202.7080701@candelatech.com> <1305851079.8149.1127.camel@tardy>
	 <4DD5B7B3.2000505@candelatech.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:35123 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932618Ab1ETAqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 20:46:21 -0400
In-Reply-To: <4DD5B7B3.2000505@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-19 at 17:37 -0700, Ben Greear wrote:
> On 05/19/2011 05:24 PM, Rick Jones wrote:
> >>>> [root@i7-965-1 igb]# netstat -an|grep tcp|grep 8.1.1
> >>>> tcp        0      0 8.1.1.1:33038               0.0.0.0:*                   LISTEN
> >>>> tcp        0      0 8.1.1.1:33040               0.0.0.0:*                   LISTEN
> >>>> tcp        0      0 8.1.1.1:33042               0.0.0.0:*                   LISTEN
> >>>> tcp        0 9328612 8.1.1.2:33039               8.1.1.1:33040               ESTABLISHED
> >>>> tcp        0 17083176 8.1.1.1:33038               8.1.1.2:33037               ESTABLISHED
> >>>> tcp        0 9437340 8.1.1.2:33037               8.1.1.1:33038               ESTABLISHED
> >>>> tcp        0 17024620 8.1.1.1:33040               8.1.1.2:33039               ESTABLISHED
> >>>> tcp        0 19557040 8.1.1.1:33042               8.1.1.2:33041               ESTABLISHED
> >>>> tcp        0 9416600 8.1.1.2:33041               8.1.1.1:33042               ESTABLISHED
> >>>
> >>> I take it your system has higher values for the tcp_wmem value:
> >>>
> >>> net.ipv4.tcp_wmem = 4096 16384 4194304
> >>
> >> Yes:
> >> [root@i7-965-1 igb]# cat /proc/sys/net/ipv4/tcp_wmem
> >> 4096	16384	50000000
> >
> > Why?!?  Are you trying to get link-rate to Mars or something?  (I assume
> > tcp_rmem is similarly set...)  If you are indeed doing one 1 GbE, and no
> > more than 100ms then the default (?) of 4194304 should have been more
> > than sufficient.
> 
> Well, we occasionally do tests over emulated links that have several
> seconds of delay and may be running multiple Gbps.  Either way,
> I'd hope that offering extra RAM to a subsystem wouldn't cause it
> to go nuts.  

It has been my experience that the autotuning tends to grow things
beyond the bandwidthXdelay product.

As for several seconds of delay and multiple Gbps - unless you are
shooting the Moon, sounds like bufferbloat?-)

> Assuming this isn't some magical 1Gbps issue, you
> could probably hit the same problem with a wifi link and
> default tcp_wmem settings...

Do you also increase tx queue's for the NIC(s)?

rick

