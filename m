From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] ipv6: clean up dev_snmp6 proc entry when we fail
 to initialize inet6_dev
Date: Wed, 04 Nov 2015 07:23:14 -0800
Message-ID: <1446650594.4184.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <94ceff1a1f708ce80664370c783f7bfb066fccb5.1446577025.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	hannes@stressinduktion.org, cwang@twopensource.com
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34697 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932317AbbKDPXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 10:23:17 -0500
Received: by padhx2 with SMTP id hx2so47827177pad.1
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 07:23:17 -0800 (PST)
In-Reply-To: <94ceff1a1f708ce80664370c783f7bfb066fccb5.1446577025.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-04 at 14:47 +0100, Sabrina Dubroca wrote:
> In ipv6_add_dev, when addrconf_sysctl_register fails, we do not clean up
> the dev_snmp6 entry that we have already registered for this device.
> Call snmp6_unregister_dev in this case.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> 
> v2: we cannot call snmp6_unregister_dev from addrconf_core.c, this
>     breaks CONFIG_IPV6=m, instead do the clean up directly from
>     ipv6_add_dev
>     thanks Cong.

Any idea when the bug was added ?

Can we please add a proper Fixes: tag for patches that need to be
backported to stable versions ?

It seems to be

Fixes: a317a2f19da7d ("ipv6: fail early when creating netdev named all or default")

So this goes back to linux-3.17 ?

Thanks a lot Sabrina !
