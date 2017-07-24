From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net] net: fix tcp reset packet flowlabel for ipv6
Date: Mon, 24 Jul 2017 13:34:55 -0700 (PDT)
Message-ID: <20170724.133455.562898067272108474.davem@davemloft.net>
References: <25a0abdf61ab4698773d417af9e49fcd6e6559a4.1500393028.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kernel-team@fb.com, shli@fb.com,
        eric.dumazet@gmail.com, flo@fourcot.fr
To: shli@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753495AbdGXUe4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 16:34:56 -0400
In-Reply-To: <25a0abdf61ab4698773d417af9e49fcd6e6559a4.1500393028.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@kernel.org>
Date: Tue, 18 Jul 2017 12:03:37 -0700

> +	/* Since this is being sent on the wire obfuscate hash a bit
> +	 * to minimize possbility that any useful information to an
> +	 * attacker is leaked. Only lower 20 bits are relevant.
> +	 */
> +	rol32(hash, 16);

This doesn't help anything at all.

I don't like things that try to give a sense of security (however
little) but actually don't give any at all.

I'd rather, therefore, that you remove this altogether.

And note that maybe not using the same flow label prevents
attacks of that nature, ever consider that?
