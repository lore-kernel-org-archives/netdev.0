From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: remove unimplemented RTNH_F_PERVASIVE
Date: Sat, 2 Apr 2016 19:04:27 +0300
Message-ID: <56FFED8B.7010701@cogentembedded.com>
References: <1459586603-24006-1-git-send-email-quentin@armitage.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Quentin Armitage <quentin@armitage.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35637 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbcDBQEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 12:04:33 -0400
Received: by mail-lf0-f45.google.com with SMTP id k79so111714657lfb.2
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 09:04:32 -0700 (PDT)
In-Reply-To: <1459586603-24006-1-git-send-email-quentin@armitage.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/2/2016 11:43 AM, Quentin Armitage wrote:

> Linux 2.1.68 introduced RTNH_F_PERVASIVE, but it had no implementation
> and couldn't be enabled since the required config parameter wasn't in
> any Kconfig file (see commit d088dde7b).

    scripts/checkpatch.pl now enforces certain commit citing format, your 
doesn't match it, i.e. you need 12-digit SHA1 and ("<commit summary") after that.

> This commit removes all remaining references to RTNH_F_PERVASIVE.
> Although this will cause userspace applications that were using the
> flag to fail to build, they will be alerted to the fact that using
> RTNH_F_PERVASIVE was not achieving anything.
>
> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
[...]

> diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
> index df48034..f5660c6 100644
> --- a/net/decnet/dn_fib.c
> +++ b/net/decnet/dn_fib.c
> @@ -243,7 +243,7 @@ out:
>   	} else {
>   		struct net_device *dev;
>
> -		if (nh->nh_flags&(RTNH_F_PERVASIVE|RTNH_F_ONLINK))
> +		if (nh->nh_flags&RTNH_F_ONLINK)

    Please enclose & into spaces like below.

> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index d97268e..3883860 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -803,7 +803,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
>   	} else {
>   		struct in_device *in_dev;
>
> -		if (nh->nh_flags & (RTNH_F_PERVASIVE | RTNH_F_ONLINK))
> +		if (nh->nh_flags & RTNH_F_ONLINK)
>   			return -EINVAL;
>
>   		rcu_read_lock();

MBR, Sergei
