From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: delete expired route in ip6_pmtu_deliver
Date: Thu, 16 Dec 2010 12:28:55 -0800 (PST)
Message-ID: <20101216.122855.48497491.davem@davemloft.net>
References: <1292116811-22216-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292116811-22216-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Vagin <avagin@openvz.org>
Date: Sun, 12 Dec 2010 04:20:11 +0300

> The first big packets sent to a "low-MTU" client correctly
> triggers the creation of a temporary route containing the reduced MTU.
> 
> But after the temporary route has expired, new ICMP6 "packet too big"
> will be sent, rt6_pmtu_discovery will find the previous EXPIRED route
> check that its mtu isn't bigger then in icmp packet and do nothing
> before the temporary route will not deleted by gc.
> 
> I make the simple experiment:
> while :; do
>     time ( dd if=/dev/zero bs=10K count=1 | ssh hostname dd of=/dev/null ) || break;
> done
> 
> The "time" reports real 0m0.197s if a temporary route isn't expired, but
> it reports real 0m52.837s (!!!!) immediately after a temporare route has
> expired.
> 
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied and queued up for -stable, thanks.
