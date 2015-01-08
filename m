From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/2] gen_stats.c: Duplicate xstats buffer for later
 use
Date: Thu, 08 Jan 2015 16:07:58 +0300
Message-ID: <54AE812E.4070508@cogentembedded.com>
References: <20150108103518.GA7214@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?ISO-8859-2?Q?Ignacy_Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:48870 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbbAHNPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 08:15:44 -0500
Received: by mail-la0-f51.google.com with SMTP id ms9so9034163lab.10
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 05:15:43 -0800 (PST)
In-Reply-To: <20150108103518.GA7214@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/8/2015 1:35 PM, Ignacy Gaw=EAdzki wrote:

> The gnet_stats_copy_app() function gets called, more often than not, =
with its
> second argument a pointer to an automatic variable in the caller's st=
ack.
> Therefore, to avoid copying garbage afterwards when calling
> gnet_stats_finish_copy(), this data is better copied to a dynamically=
 allocated
> memory that gets freed after use.

> Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communication=
s.fr>
> ---
>   net/core/gen_stats.c | 17 ++++++++++++++---
>   1 file changed, 14 insertions(+), 3 deletions(-)

> diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
> index 0c08062..5770a0e 100644
> --- a/net/core/gen_stats.c
> +++ b/net/core/gen_stats.c
> @@ -305,7 +305,10 @@ int
>   gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
>   {
>   	if (d->compat_xstats) {
> -		d->xstats =3D st;
> +		d->xstats =3D kmalloc(len, GFP_KERNEL);
> +		if (!d->xstats)
> +			goto kmalloc_failure;
> +		memcpy(d->xstats, st, len);

    Please use kmemdup() instead of kmalloc()/memcpy().

[...]

WBR, Sergei
