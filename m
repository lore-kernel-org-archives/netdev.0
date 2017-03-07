From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] net: Eliminate duplicated codes by creating
 one new function in_dev_select_addr
Date: Tue, 7 Mar 2017 18:46:22 +0300
Message-ID: <b2c1e98f-427f-8796-ddbe-bd4eebf6b94e@cogentembedded.com>
References: <1488898279-18930-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: fgao@ikuai8.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:34318 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755582AbdCGPqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 10:46:35 -0500
Received: by mail-lf0-f44.google.com with SMTP id k202so2704226lfe.1
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 07:46:25 -0800 (PST)
In-Reply-To: <1488898279-18930-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 03/07/2017 05:51 PM, fgao@ikuai8.com wrote:

> From: Gao Feng <fgao@ikuai8.com>
>
> There are two duplicated loop codes which used to select right

    Just "loops".

> address in current codes. Now eliminate these codes by creating
> one new function in_dev_select_addr.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  net/ipv4/devinet.c | 34 +++++++++++++++++++---------------
>  1 file changed, 19 insertions(+), 15 deletions(-)
>
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 1a9e550..d0964c5 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1191,6 +1191,19 @@ static int inet_gifconf(struct net_device *dev, char __user *buf, int len)
>  	return done;
>  }
>
> +static __be32 in_dev_select_addr(const struct in_device *in_dev,
> +				 int scope)
> +{
> +	for_primary_ifa(in_dev) {
> +		if (ifa->ifa_scope != RT_SCOPE_LINK &&
> +		    ifa->ifa_scope <= scope) {
> +			return ifa->ifa_local;
> +		}

    Could drop the useless {} here, while at it.

> +	} endfor_ifa(in_dev);
> +
> +	return 0;
> +}
> +
>  __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
>  {
>  	__be32 addr = 0;
[...]

MBR, Sergei
