From: Joe Perches <joe@perches.com>
Subject: RE: printk_ratelimit and net_ratelimit conflict and tunable
	behavior
Date: Mon, 25 Feb 2008 12:13:37 -0800
Message-ID: <1203970417.19319.287.camel@localhost>
References: <7BFDACCD6948EF4D8FE8F4888A91596A016371E8@tx14exm60.ds.mot.com>
	 <20080220.223219.165157596.davem@davemloft.net>
	 <1203577246.7181.241.camel@localhost>
	 <7BFDACCD6948EF4D8FE8F4888A91596A016371FA@tx14exm60.ds.mot.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hawkes Steve-FSH016 <Steve.Hawkes@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1151 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756366AbYBYUOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 15:14:01 -0500
In-Reply-To: <7BFDACCD6948EF4D8FE8F4888A91596A016371FA@tx14exm60.ds.mot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-25 at 09:47 -0600, Hawkes Steve-FSH016 wrote:
> How about this?

line wrapped, but seems better.

> Signed-off-by: Steve Hawkes <steve.hawkes@motorola.com> 
> 
> diff -uprN linux-2.6.24/include/linux/kernel.h
> linux-2.6.24-printk_ratelimit/include/linux/kernel.h
> --- linux-2.6.24/include/linux/kernel.h 2008-01-24 16:58:37.000000000
> + * This enforces a rate limit to mitigate denial-of-service attacks:
> + * not more than ratelimit_burst messages every ratelimit_jiffies.
>   */
> -int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst)
> +int __printk_ratelimit(int ratelimit_jiffies,
> +                       int ratelimit_burst,
> +                       struct printk_ratelimit_state *state)

I think the value of in-place tunables is low.
I'd remove that bit and use the struct printk_ratelimit_state.

David Miller points out that struct initializations to 0 or NULL
are not necessary.

