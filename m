From: Damien Wyart <damien.wyart@free.fr>
Subject: Re: [PATCH] e100_shutdown: netif_poll_disable hang
Date: Sat, 21 Oct 2006 19:41:15 +0200
Message-ID: <87slhh1s90.fsf@brouette.noos.fr>
References: <20061020182820.978932000@mvista.com> <453936E0.1010204@intel.com>
	<45393B0B.8090301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Walker <dwalker@mvista.com>, Andrew Morton <akpm@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pm-mx5.mgn.net ([195.46.220.209]:41915 "EHLO pm-mx5.mgn.net")
	by vger.kernel.org with ESMTP id S2993124AbWJURlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 13:41:17 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45393B0B.8090301@intel.com> (Auke Kok's message of "Fri\, 20 Oct
	2006 14\:09\:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > My machine annoyingly hangs while rebooting. I tracked it down to
> > > e100-fix-reboot-f-with-netconsole-enabled.patch in 2.6.18-rc2-mm2
> > > I review the changes and it seemed to be calling
> > > netif_poll_disable one too many time. Once in e100_down(), and
> > > again in e100_shutdown().
> > > The second one in e100_shutdown() caused the hang. So this patch
> > > removes it.

* Auke Kok <auke-jan.h.kok@intel.com> [061020 23:09]:
> it doesn't even do harm to netif_poll_disable() twice as far as I can
> see, as it merely calls test_and_set_bit(), which will instantly
> succeed on the first attempt if the bit was already set.

> did this change actually fix it for you? I'm wondering if the
> netif_carrier_off might not be the culprit here...

I can confirm the proposed original change of D. Walker fixed the
problem for me. I did not test the change you proposed as a followup.

-- 
Damien Wyart
