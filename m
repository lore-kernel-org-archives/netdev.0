From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: NMI lockup, 2.6.26 release
Date: Wed, 13 Aug 2008 11:02:34 +0300
Message-ID: <200808131102.34988.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <200808131028.11153.denys@visp.net.lb> <20080813074326.GB5367@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:56369 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125AbYHMIDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 04:03:34 -0400
In-Reply-To: <20080813074326.GB5367@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As soon as kernel reboot themself, it won't hurt me much.
With NMI watchdog i notice there was panic missing, so nmi_watchdog was 
showing message and was not rebooting. It is fixed in next kernel and i patch 
in my kernel - so i will not crash+freeze anymore i guess and will not need 
to run to power switch at night.

It can be related to another problem (some corruption) which is not fixed yet, 
so prefferably to show timer guys exact location of problem.

Maybe you can make some patch like:

+	if (q->next_watchdog < q->now || next_event <=
+	     q->next_watchdog - PSCHED_TICKS_PER_SEC / (10 * HZ)) {
+		qdisc_watchdog_schedule(&q->watchdog, next_event);
+		q->next_watchdog = next_event;
+	} else {
something like BUG()
         }
?
Probably also i will try to migrate to "rc" versions of kernel to see if 
problem still exist there, a lot of changes done there... is HTB corruption 
problem tracked finally and completely? I seen some discussions about it 
recently...

On Wednesday 13 August 2008, Jarek Poplawski wrote:
> On Wed, Aug 13, 2008 at 10:28:11AM +0300, Denys Fedoryshchenko wrote:
> > Just as proposal, maybe we can catch situation when "things going wrong"
> > and panic? So we can forward some info to hrtimers guys?
> > If it is hrtimers bug...
>
> Yes, it would be the best, but I don't know how much I can "use" you
> and your clients for debugging this. So, of course, if it's possible
> you could simply edit this patch and try with increased values like
> (100 * HZ) or (1000 * HZ), or even something like:
>
> +	if (q->next_watchdog < q->now || next_event <=
> +	     q->next_watchdog - 10) {
>
> Alas hrtimers guys didn't look like very interested, so the main
> concern should be doing this optimal in net at least.
>
> Jarek P.
>


