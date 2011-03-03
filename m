From: John Heffner <johnwheffner@gmail.com>
Subject: Re: A misbehavior of handling TCP out of band data ?
Date: Thu, 3 Mar 2011 14:23:57 -0500
Message-ID: <AANLkTimOYmVPGadN=G5QkNxZZuf8PecemYgNLvSSVZ=c@mail.gmail.com>
References: <AANLkTinEBm1WuS9nRv3UcyoL4MJwBsqbukXUcUjHZQgU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61735 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab1CCTX7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 14:23:59 -0500
Received: by yxs7 with SMTP id 7so489673yxs.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 11:23:58 -0800 (PST)
In-Reply-To: <AANLkTinEBm1WuS9nRv3UcyoL4MJwBsqbukXUcUjHZQgU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This feature is only here to support legacy applications, and really
should not be used.  See RFC 6093.  http://tools.ietf.org/html/rfc6093

  -John


On Thu, Mar 3, 2011 at 10:24 AM, Li Yu <raise.sail@gmail.com> wrote:
> Hi,
>
> =A0 =A0 =A0 =A0In my words, if we did not turn on SO_OOBINLINE at rec=
eiver,
> any OOB bytes do not have to be read from regular TCP byte stream.
>
> =A0 =A0 =A0 =A0But in below extreme case: the sender process have a l=
oop to
> send 1 OOB byte 'O' and 1 byte normal data 'D', the receiver ignore
> all OOB data, so if OOB feature works well, the receiver should
> receive 'D' only, However, in fact, the receiver still can see OOB
> bytes by recv() syscall without MSG_OOB flag.
>
> =A0 =A0 =A0 =A0I found that we may send "ODODODODODOD...." in a tcp s=
egment,
> and tcp_sendmsg() has no special code to avoid this.
>
> =A0 =A0 =A0 =A0Well, I know that it seem that above case is too extre=
me to
> use in actual environment, but above is simplified from our actual
> scenario.
>
> =A0 =A0 =A0 =A0Anyway, I think that overwriting or skip previous OOB =
bytes is
> acceptable, but leave them in regular TCP byte stream likely is a bug=
=2E
> En, probably, the disabled SO_OOBINLINE just is a feature of receiver
> side, sender do not need to have to guarantee it?
>
> =A0 =A0 =A0 =A0Thanks.
>
> Yu
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
