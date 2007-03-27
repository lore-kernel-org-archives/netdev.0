From: "Denys" <denys@visp.net.lb>
Subject: Re: more... iproute2/htb/whatever critical bug ?
Date: Tue, 27 Mar 2007 18:18:57 +0300
Message-ID: <20070327151659.M74386@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb>	<46026717.9060909@trash.net>	<20070322124533.M79867@visp.net.lb>	<46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty> <4602B96A.5000308@trash.net> <20070326182654.M24011@visp.net.lb> <460933EC.9060908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:44555 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895AbXC0PTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 11:19:33 -0400
In-Reply-To: <460933EC.9060908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, correct, i am able to reproduce problem, i was scared i will be not able.
Just when i am killing pppd on "server" side, flooding interface, it's 
happens.

I will try patch in next 30 minutes max.

I have also bug, related to mirred to ifb0 and ethernet checksum offloading, 
but maybe it is fixed. I will try to remember, to tell about it. I dont have 
right now local computer with checksum offloading capable card, it also 
causing kernel panic, but i workaround it by ethtool, disabling feature.

On Tue, 27 Mar 2007 17:10:36 +0200, Patrick McHardy wrote
> Denys wrote:
> > Mar 26 21:20:04 ROUTER-75 [  551.481081] BUG: unable to handle kernel 
NULL 
> > pointer dereference
> > Mar 26 21:20:04 ROUTER-75 at virtual address 00000074
> > Mar 26 21:20:04 ROUTER-75 [  551.481187]  printing eip:
> > Mar 26 21:20:04 ROUTER-75 [  551.481236] f8a11df1
> > Mar 26 21:20:04 ROUTER-75 [  551.481289] *pde = 00000000
> > Mar 26 21:20:04 ROUTER-75 [  551.481340] Oops: 0000 [#1]
> > Mar 26 21:20:04 ROUTER-75 [  551.481384]
> > Mar 26 21:20:04 ROUTER-75 SMP
> > Mar 26 21:20:04 ROUTER-75
> > Mar 26 21:20:04 ROUTER-75 [  551.481549] Modules linked in:
> > .... long module list
> > ar 26 21:20:04 ROUTER-75 [  551.485237] CPU:    0
> > Mar 26 21:20:04 ROUTER-75 [  551.485238] EIP:    0060:[<f8a11df1>]    Not 
> > tainted VLI
> > Mar 26 21:20:04 ROUTER-75 [  551.485239] EFLAGS: 00010282   (2.6.20.3-
build-
> > 0001 #4)
> > Mar 26 21:20:04 ROUTER-75 [  551.485438] EIP is at htb_qlen_notify+0x9/
0x79 
> > [sch_htb]
> 
> Oops, that seems to be my fault. Can you please try the attached patch?
> To reproduce the problem you need to have packets queued while the
> device is going down, so please make sure that is true by flooding
> the device or something like that.


--
Virtual ISP S.A.L.

