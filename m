From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][netdev-next] gre: remove duplicated assignment of iph
Date: Wed, 23 Aug 2017 11:46:11 -0700 (PDT)
Message-ID: <20170823.114611.1764472622798498530.davem@davemloft.net>
References: <20170823111305.19185-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170823111305.19185-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed, 23 Aug 2017 12:13:05 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> iph is being assigned the same value twice; remove the redundant
> second assignment.
> 
> Fixes warning:
> net/ipv4/ip_gre.c:265:2: warning: Value stored to 'iph' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

It is always necessary to reload any SKB header pointer after calls
to functions which potentially change the data buffer of the SKB.

pskb_may_pull() is one such call.

Therefore your patch is adding a bug.

If you want to remove the dup, you must remove the first not
the second one.
