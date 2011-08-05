From: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Fri, 5 Aug 2011 16:40:17 +0200
Message-ID: <20110805144017.GA20006@colin.search.kasperd.net>
References: <20110728084821.GA24125@colin.search.kasperd.net> <20110728105831.GA11385@electric-eye.fr.zoreil.com> <20110728114305.GA24549@colin.search.kasperd.net> <20110728115936.GC24549@colin.search.kasperd.net> <20110728122328.GA11424@electric-eye.fr.zoreil.com> <20110728124548.GA24762@colin.search.kasperd.net> <20110728125437.GA24876@colin.search.kasperd.net> <20110728144719.GA11465@electric-eye.fr.zoreil.com> <20110728210112.GA25953@colin.search.kasperd.net> <20110805140047.GA19758@colin.search.kasperd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nfitmail.nfit.au.dk ([130.225.31.129]:28195 "EHLO
	smtp.nfit.au.dk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755525Ab1HEOkU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 10:40:20 -0400
Content-Disposition: inline
In-Reply-To: <20110805140047.GA19758@colin.search.kasperd.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/11 16.08, Kasper Dupont wrote:
> At that point it did not itterate through the loop again
> and it did not leave the interrupt handler either. I'll
> power cycle the machine and take a closer look on the
> source to see what could possible be happening at that
> point.

I looked at the source around the place where that lockup
happened. There was absolutely no I/O or loops happening
between the two printk calls. It seemed the only real
candidate for a culprit responsible for that lockup was
the printk calls themselves.

Is it plausible that in 2.6.32.43 it is not safe to call
printk from within an interrupt handler?

I added some more printk statements in an attempt to find
out how it was possible for the code to lock up between
the end of the loop and the exit from the interrupt handler.

I wasn't able to reproduce the lockup in the same spot, but
instead I saw a lockup inside the loop in the branch where
it does netif_stop_queue.

Right now I suspect those builds where I added printk
statements lockup due to the printk statements. But does
the plain 2.6.32.43 kernel then also lockup due to printk
statements in the interrupt handler, or is it something
else?

--=20
Kasper Dupont -- Rigtige m=E6nd skriver deres egne backupprogrammer
#define _(_)"d.%.4s%."_"2s" /* This is my email address */
char*_=3D"@2kaspner"_()"%03"_("4s%.")"t\n";printf(_+11,_+6,_,11,_+2,_+7=
,_+6);
