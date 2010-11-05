From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Fri, 5 Nov 2010 14:40:38 +0800
Message-ID: <AANLkTikr8mNkap0skgAPdNFTjv3LhoGGXQwrUz5hBT1K@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
 <20101025213841.635b9a15@nehalam> <AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
 <20101026082832.4c5af2ef@nehalam> <1288666459.4003.47.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4489 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab0KEGlC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 02:41:02 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id oA56f1bE001765
	for <netdev@vger.kernel.org>; Thu, 4 Nov 2010 23:41:01 -0700
Received: from gxk2 (gxk2.prod.google.com [10.202.11.2])
	by kpbe18.cbf.corp.google.com with ESMTP id oA56excA015475
	for <netdev@vger.kernel.org>; Thu, 4 Nov 2010 23:41:00 -0700
Received: by gxk2 with SMTP id 2so2160591gxk.14
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 23:40:59 -0700 (PDT)
In-Reply-To: <1288666459.4003.47.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 2, 2010 at 10:54 AM, Dan Williams <dcbw@redhat.com> wrote:
> For this sort of thing, I tend to think that only higher-level networ=
k
> management daemons like NM have the *possibility* to get this sort of
> thing right, because only they have overall knowledge of the networki=
ng
> situation, like whether you've actually connected to a different netw=
ork
> or not. =A0Specifically in the case of wifi, only the connection mana=
ger
> (or wpa_supplicant) knows whether you're on a different network or =A0=
not,
> anything else is a layering violation.

Maybe you're right and everything should be done in userspace. But for
now, the kernel is still processing RAs itself and adding IPv6
addresses to interfaces itself. If we don't intend to rip that all out
and replace it with a userspace implementation, then we should fix the
kernel to be a little smarter and not keep addresses around when they
are not useful any more.

This can be done relatively in a hitless fashion by putting old
addresses into the deprecated state until they are refreshed by an RA,
etc.

I don't think it's reasonable to say that we need a network management
daemon because we need to delete addresses that the kernel created and
the kernel can't be bothered to clean up after itself.

Cheers,
Lorenzo
