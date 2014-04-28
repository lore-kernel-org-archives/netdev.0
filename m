From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next 1/4] net: ipv6: Introduce flowi6_init_output.
Date: Mon, 28 Apr 2014 10:07:27 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404280949410.1587@ja.home.ssi.bg>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com> <1398487705-13430-2-git-send-email-lorenzo@google.com> <alpine.LFD.2.11.1404260850030.1554@ja.home.ssi.bg> <CAKD1Yr1EYAWEoQyAZWOKb0-YwkYP1tq8S+ywkk0=q9Hz+SfDtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, JP Abgrall <jpa@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33356 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753178AbaD1HHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 03:07:38 -0400
In-Reply-To: <CAKD1Yr1EYAWEoQyAZWOKb0-YwkYP1tq8S+ywkk0=q9Hz+SfDtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 27 Apr 2014, Lorenzo Colitti wrote:

> On Sat, Apr 26, 2014 at 2:56 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >> +     fl6->flowi6_oif = oif;
> >> +     fl6->flowi6_iif = 0;
> >
> >         Make sure LOOPBACK_IFINDEX is provided in
> > flowi6_iif instead of 0, recent commit fixed such
> > FIB rule lookups.
> 
> I'm assuming that was for IPv4? All the IPv6 code in current net-next
> still seems to set flowi6_iif to zero. It's later set to
> LOOPBACK_IFINDEX in ip6_route_output.

	I see, it seems more IPv6 places need a fix.

> You could argue that if this patch is accepted, then setting
> flowi6_iif to LOOPBACK_IFINDEX belongs there for consistency with
> IPv4. That seems reasonable, but I'd prefer not doing that in this
> patch because 1) this patch is semantically a no-op and I'd like to
> keep it that way, 2) it would be a bigger change, because even with
> this patch, there are still codepaths that initialize their own flowi6
> and memset them to zero.

	OK. I'll try a patch to fix the remaining flowi6_iif
places...

Regards

--
Julian Anastasov <ja@ssi.bg>
