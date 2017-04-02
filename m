From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 1/1] net: tcp: Define the TCP_MAX_WSCALE instead
 of literal number 14
Date: Sun, 2 Apr 2017 14:59:25 -0400
Message-ID: <CADVnQy=WSQb0bz-gRFfNK8uTyJ-ALdUPhR05iThZ8fs=K=qm2w@mail.gmail.com>
References: <1491020050-118525-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Netdev <netdev@vger.kernel.org>, Gao Feng <fgao@ikuai8.com>
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33095 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdDBS74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 14:59:56 -0400
Received: by mail-oi0-f42.google.com with SMTP id b187so105561614oif.0
        for <netdev@vger.kernel.org>; Sun, 02 Apr 2017 11:59:56 -0700 (PDT)
In-Reply-To: <1491020050-118525-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 1, 2017 at 12:14 AM,  <gfree.wind@foxmail.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> Define one new macro TCP_MAX_WSCALE instead of literal number '14',
> and use U16_MAX instead of 65535 as the max value of TCP window.
> There is another minor change, use rounddown(space, mss) instead of
> (space / mss) * mss;
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---

Looks OK to me.

IMHO this is a nice direction, since there is a proposal to increase
the maximum shift factor from 14 to 15:
  https://tools.ietf.org/html/draft-nishida-tcpm-maxwin-03

Though there are a few spots where a literal 14 appears:

tcp_input.c:3763:  net_info_ratelimited("%s: Illegal window scaling
value %d >14 received\n",

tcp_output.c:238:                * See RFC1323 for an explanation of
the limit to 14


neal
