From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH] af_unix: implement socket filter
Date: Tue, 18 Jan 2011 17:51:43 +0000
Message-ID: <20110118175143.3a164669@chocolatine.cbg.collabora.co.uk>
References: <1295368755-20931-1-git-send-email-ian.molton@collabora.co.uk>
	<1295371361.3290.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, ebiederm@xmission.com, xemul@openvz.org,
	davidel@xmailserver.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Ian Molton <ian.molton@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:58899 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042Ab1ARSEe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 13:04:34 -0500
In-Reply-To: <1295371361.3290.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tue, 18 Jan 2011 18:22:41 +0100,
Eric Dumazet <eric.dumazet@gmail.com> a =C3=A9crit :

> Le mardi 18 janvier 2011 =C3=A0 16:39 +0000, Ian Molton a =C3=A9crit =
:
> > From: Alban Crequy <alban.crequy@collabora.co.uk>
> >=20
> > Linux Socket Filters can already be successfully attached and
> > detached on unix sockets with setsockopt(sockfd, SOL_SOCKET,
> > SO_{ATTACH,DETACH}_FILTER, ....). See:
> > Documentation/networking/filter.txt
> >=20
> > But the filter was never used in the unix socket code so it did not
> > work. This patch uses sk_filter() to filter buffers before delivery=
=2E
> >=20
> > This short program demonstrates the problem on SOCK_DGRAM.

By the way, the patch implements socket filters on SOCK_DGRAM and
SOCK_SEQPACKET but not SOCK_STREAM. Socket filters does not make sense
to me when there is no packet boundaries. But if there is a need for
it, the code for SOCK_STREAM could be added easily.

> Any idea on performance cost adding sk_filter() call ?

Ian will write a performance test and repost the patch with some stats.
I don't know about the performance cost.

> Hmm, looking at it, I have no idea why sk_filter() needs to block BH.

I don't know neither.

> I'll send a patch to relax this requirement.

Thanks for your review!

Alban
