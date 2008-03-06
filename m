From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 6 Mar 2008 17:50:59 +0200
Message-ID: <20080306143910.M91001@visp.net.lb>
References: <20080224222035.M62480@visp.net.lb> <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local>  <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:52153 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207AbYCFPvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 10:51:18 -0500
In-Reply-To: <1204813634.4440.59.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Mar 2008 09:27:14 -0500, jamal wrote
> On Thu, 2008-06-03 at 15:57 +0200, Denys Fedoryshchenko wrote:
> > I am able to reproduce this warning over this relatively simple shell 
script
> > on my Gentoo PC (2.6.25-rc3).
> > http://www.nuclearcat.com/files/bug_feb.txt
> >
> 
> That script looks pretty sane to me - nothing super-exciting. I suspect
> you eventually want them all to look like ifb1 on the egress.
> Do you see the same issue without the ifb1 speacial case?
Well, i am able to reproduce in much more trivial script. Tested 2.6.25-rc4 
also.

modprobe ifb
ifconfig ifb0 up
TC=/sbin/tc
$TC qdisc del dev eth0 ingress 1>/dev/null 2>/dev/null
$TC qdisc add dev eth0 ingress
${TC} filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
      match u32 0 0 flowid 1:1 \
      action mirred egress redirect dev ifb0

> 
> > Probably it will help to debug issue for more experienced developers. 
Note:
> > it appears not immediately, second time i tested, it's appeared after 
while,
> > but in matter of seconds.
> 
> I wonder is there some latency from the moment you insmod ifb to the
> moment the tc rules take effect? Will it still happen if you dont 
> have modules? Also note, that lock dependency is a bit strange,
>  Jarek correct me if i am wrong; it seems to say: a packet received 
> on ingress of some e1000 (ethx) gets acted on by mirred which ends 
> grabbing lock of an ifb device - this part should be fine and no 
> need for the alarm. The alarm seems to be a result of a loopback 
> device that is being registered in between the two activities.
> i.e there are three devices affected with entirely different 
> locks(ethx, ifbx, and loopback). Smells like lockdep is getting it wrong?
No idea, i have strange lockup's on my systems where i have ifb, and that 
make me worry. And i feel it is directly related with my love to use ifb 
devices and way how i am using them.

> 
> > Note - it can stop traffic on PC completely. It is also seems crashed my 
> > desktop PC, i am not able to execute "tc qdisc del dev eth0 root".
> > The system hang completely. I had few similar issues on my PPPoE servers 
> > (with different scripts for shapers), that system hang, and even "reboot -
f" 
> > doesn't work sometimes.
> 
> This sounds like a different issue from above - when did this start 
> to happen? Is it at the same time as above warnings showing up?

Yes, it is different issue seems, it is rare to lockup system , and i will 
dig more, to understand how it is happening.

> 
> cheers,
> jamal
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

