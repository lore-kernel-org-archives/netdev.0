From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: + ppp_generic-fix-lockdep-warning.patch added to -mm tree
Date: Tue, 17 Apr 2007 09:37:44 +0200
Message-ID: <20070417073744.GA1976@ff.dom.local>
References: <20070411000932.1f00f395.akpm@linux-foundation.org> <028701c77c16$bcd68a90$0202fea9@Jura>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	Michal Ostrowski <mostrows@speakeasy.net>
To: "Yuriy N\. Shkandybin" <jura@netams.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:35870 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752306AbXDQHcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 03:32:13 -0400
Content-Disposition: inline
In-Reply-To: <028701c77c16$bcd68a90$0202fea9@Jura>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2007 at 12:52:28PM +0400, Yuriy N. Shkandybin wrote:
...
> >On Wed, 11 Apr 2007 09:57:33 +0400 "Yuriy N. Shkandybin" <jura@netams.com> 
> >wrote:
> >
> >>I've tested  2.6.21-rc6-mm1
> >>Linux vpn1 2.6.21-rc6-mm1 #4 SMP Wed Apr 11 03:34:26 MSD 2007 x86_64
> >>Intel(R) Pentium(R) D CPU 2.80GHz GenuineIntel GNU/Linux
> >>
> >>warn appeares upon first pppoe connection to rp-pppoe server in kernel 
> >>mode
> >>
> >
> >Thanks.  So you're saying that
> >ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.21-rc6/2.6.21-rc6-mm1/broken-out/ppp_generic-fix-lockdep-warning.patch
> >did not fix anything?
> As i understand this patch already in -mm tree, so I've booted into last mm 
> kernel and received this locked warning.
> Or i've mistaked and should apply this patch manually?

Hi!

Yuriy - thanks for testing my patch ...(pause) Not!

It seems this patch is not visible in this version - probably
is overpatched by something else. But your new log shows there
is another connection between these locks (ppp_xmit_process
and ppp_push instead of ppp_channel_push in "-> #0"), so the
patch is not sufficient (and could be dumped).

I don't know your vlans configuration, but it seems the real
lockup isn't very probable here - it's rather lockdep question.
I think vlan's too broad lockdep class is the main "guilty"
here, but probably pppoe also could be enhanced: it's making
the things unnecessarily complicated by calling dev_queue_xmit
under ppp_generic's xmit locks. I wonder if there is any reason
against using a tasklet here.

I'll try to find more time to untie this yet - or maybe some
maintainer will find this interesting, too...

Regards,
Jarek P.

PS: sorry for late responding (vacations).
