From: Hannes Frederic Sowa <hannes@mailcolloid.de>
Subject: Re: [PATCH V3 2/2] bonding support for IPv6 transmit hashing
Date: Sat, 30 Jun 2012 13:59:54 +0200
Message-ID: <CAMEyesBOj2cd6sAmowjk1vATrMjxHreeJoDEdksVwENkEWWqLQ@mail.gmail.com>
References: <4FEE99EE.2000001@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: John <linux@8192.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:57060 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754404Ab2F3L74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 07:59:56 -0400
Received: by lbbgm6 with SMTP id gm6so5764150lbb.19
        for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 04:59:54 -0700 (PDT)
In-Reply-To: <4FEE99EE.2000001@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 30, 2012 at 8:17 AM, John <linux@8192.net> wrote:
> diff --git a/Documentation/networking/bonding.txt
> b/Documentation/networking/bonding.txt
> index bfea8a3..5db14fe 100644
> --- a/Documentation/networking/bonding.txt
> +++ b/Documentation/networking/bonding.txt
> @@ -752,12 +752,22 @@ xmit_hash_policy
>                 protocol information to generate the hash.
>
>                 Uses XOR of hardware MAC addresses and IP addresses to
> -               generate the hash.  The formula is
> +               generate the hash.  The IPv4 formula is
>
>                 (((source IP XOR dest IP) AND 0xffff) XOR
>                         ( source MAC XOR destination MAC ))
>                                 modulo slave count
>
> +               The IPv6 forumla is
> +
> +               iphash =
> +                       (source ip quad 2 XOR dest IP quad 2) XOR
> +                       (source ip quad 3 XOR dest IP quad 3) XOR
> +                       (source ip quad 4 XOR dest IP quad 4)
> +
> +               ((iphash >> 16) XOR (iphash >> 8) XOR iphash)
> +                       modulo slave count
> +

Wouldn't it be beneficial to include the ipv6 flow label in the hash
calculation?

Greetings,

  Hannes
