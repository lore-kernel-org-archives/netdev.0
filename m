From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCHv2 net] net: restore lro after device detached from bridge
Date: Tue, 3 Feb 2015 07:54:30 +0100
Message-ID: <20150203065430.GB8655@unicorn.suse.cz>
References: <1422621209-23222-1-git-send-email-fan.du@intel.com>
 <54CBEE24.8000603@redhat.com>
 <54CEDEDC.7060507@gmail.com>
 <20150202111556.GA8655@unicorn.suse.cz>
 <54D0326C.2050704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Fan Du <fan.du@intel.com>, bhutchings@solarflare.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60929 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933871AbbBCGyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 01:54:33 -0500
Content-Disposition: inline
In-Reply-To: <54D0326C.2050704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2015 at 10:29:00AM +0800, Fan Du wrote:
> =E4=BA=8E 2015=E5=B9=B402=E6=9C=8802=E6=97=A5 19:15, Michal Kubecek =E5=
=86=99=E9=81=93:
> >On Mon, Feb 02, 2015 at 10:20:12AM +0800, Fan Du wrote:
> >
> >>Note, SRC is defaulted to *ON* in practice for ALL ixgbe NICs, as s=
ame
> >>other RSC capable NICs.
> >
> >A very bad idea, IMHO. A lot of bug reports resulted from it.
>=20
> Why are you saying this an idea?? this a fact for all RSC capable NIC
> drivers.  search drivers/net/ethernet/ to find more.

I didn't say it's not turned on by default, I just said I consider this
a bad idea. Why? Because the feature is known to break network
communication in common and frequently used scenarios (essentially
whenever received packets may leave the host). When this happens, you
observe strange networking malfunction and unless you know this may be
the cause (or read release notes very carefully), it's very difficult t=
o
identify the cause. Personally, I handled four bug reports of this type
in last three years.

On the other hand, having it turned off when it could be on is only a
performance problem and the communication works. When you are tuning th=
e
performance, you obviously look at the offloading features and check
which could be turned on.

This disbalance (broken communication on one side and slight performanc=
e
difference on the other) is why I believe feature like this should not
be turned on by default. Unfortunately it is and we have to deal with
it; that's why dev_disable_lro() is called in certain situations and wh=
y
it is propagated down lo lower devices. Turning it back on without
carefully checking that _none_ of the reasons to have it off exists
would do more harm than good.

                                                        Michal Kubecek
