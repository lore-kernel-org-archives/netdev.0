From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 net-next 2/2] net: print net_device reg_state in
 netdev_* unless it's registered
Date: Thu, 17 Jul 2014 12:21:39 -0700
Message-ID: <1405624899.14358.8.camel@joe-AO725>
References: <1405619171-18172-1-git-send-email-vfalico@gmail.com>
	 <1405619171-18172-3-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0013.hostedemail.com ([216.40.44.13]:49796 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752118AbaGQTVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 15:21:46 -0400
In-Reply-To: <1405619171-18172-3-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 19:46 +0200, Veaceslav Falico wrote:
[]
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
[]
> @@ -3444,7 +3459,8 @@ do {								\
>   * file/line information and a backtrace.
>   */
>  #define netdev_WARN(dev, format, args...)			\
> -	WARN(1, "netdevice: %s\n" format, netdev_name(dev), ##args)
> +	WARN(1, "netdevice: %s%s\n" format, netdev_name(dev),	\
> +	     netdev_reg_state(dev), ##args)

trivia:

My preference for style here is to have the format
and args on one line when it fits and separate
the format and args lines when they don't.

	WARN(1, "netdevice: %s%s\n" format,
	     netdev_name(dev), netdev_reg_state(dev), ##args)

Unrelated:  maybe it'd be better to change the '\n' to ": "

> diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
[]
> -		res = printk(KERN_DEBUG "%s: %pV", netdev_name(dev), &vaf);
> +		res = printk(KERN_DEBUG "%s%s: %pV", netdev_name(dev),
> +			     netdev_reg_state(dev), &vaf);

etc...
