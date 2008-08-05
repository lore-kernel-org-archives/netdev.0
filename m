From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 14:13:58 +0300
Message-ID: <200808051413.58795.denys@visp.net.lb>
References: <20080805110453.GA6541@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:43256 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803AbYHELOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 07:14:43 -0400
In-Reply-To: <20080805110453.GA6541@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 August 2008, Jarek Poplawski wrote:
> On 05-08-2008 12:05, Denys Fedoryshchenko wrote:
> > I found, that packetloss happening when i am deleting/adding classes.
> > I attach result of oprofile as file.
>
> ...
>
> Deleting of estimators (gen_kill_estimator) isn't optimized for
> a large number of them, and it's a known issue. Adding of classes
> shouldn't be such a problem, but maybe you could try to do this
> before adding filters directing to those classes.
>
> Since you can control rate with htb, I'm not sure you really need
> policing: at least you could try if removing this changes anything.
> And I'm not sure: do these tx hangs happen only when classes are
> added/deleted or otherwise too?
>
> Jarek P.

Policer is creating burst for me.
For example first 2Mbyte(+rate*time if need more precision) will pass on high 
speed (1Mbit), then if flow is still using maximum bandwidth will be 
throttled to rate of HTB. When i tried to play with cburst/burst values in 
HTB i was not able to archieve same results. I can do same with TBF and his 
peakrate/burst, but not with HTB.

It happens when root qdisc deleted(which holds around 130 child classes). 
Probably gen_kill_estimator taking all resources while i am deleting root 
class.
I did some test, on machine with 150 ppp interfaces (Pentium 4 3.2 Ghz),
just by deleting root qdisc and i got huge packetloss. When i am just adding 
classes - there is no significant packetloss.
Probably it is not right thing, when i am deleting qdisc on ppp - causing 
packetloss on whole system? Is it possible to workaround, till 
gen_kill_estimator will be rewritten?

But sure i can try to avoid "mass deleting" classes, but i think many people 
will hit this bug, especially newbies, who implement "many class" setup.

