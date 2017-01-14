From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 02/13] net: ethernet: aquantia: Common functions and
 definitions
Date: Fri, 13 Jan 2017 20:32:02 -0500 (EST)
Message-ID: <20170113.203202.1959215027883107709.davem@davemloft.net>
References: <cover.1484283610.git.vomlehn@texas.net>
        <fe1664e502d28bcb6a5689787b8000e6c9288307.1484283610.git.vomlehn@texas.net>
        <2c056fd544958594f6356a17892c251ea26ea8c8.1484283610.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vomlehn@texas.net,
        Simon.Edelhaus@aquantia.com, Dmitrii.Tarakanov@aquantia.com,
        Pavel.Belous@aquantia.com, Dmitry.Bezrukov@aquantia.com
To: Alexander.Loktionov@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60694 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdANBcF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 20:32:05 -0500
In-Reply-To: <2c056fd544958594f6356a17892c251ea26ea8c8.1484283610.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Date: Thu, 12 Jan 2017 21:02:18 -0800

> +#define AQ_OBJ_HEADER spinlock_t lock; atomic_t flags; atomic_t busy_count
> +
> +struct aq_obj_s {
> +	AQ_OBJ_HEADER;
> +};

Please don't hide multiple declarations and types inside of a macro,
that makes the code harder to understand.

Use a sub-structure or similar, and pass that sub-structure to the
handlers.

> +#define AQ_OBJ_TST(_OBJ_, _FLAG_)  ((_FLAG_) & atomic_read(&(_OBJ_)->flags))
> +
> +#define AQ_OBJ_SET(_OBJ_, _F_) \
 ...
> +#define AQ_OBJ_CLR(_OBJ_, _F_) \

Please don't reinvent the wheel.

Use test_bit, set_bit, clear_bit, test_and_set_bit, and
test_and_clear_bit.  Using an atomic_t for flag bits is completely
inappropriate, that type is primarily meant for atomic counters.

The appropriate type for *_bit() operations is "unsigned long".
