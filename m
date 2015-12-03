From: David Miller <davem@davemloft.net>
Subject: Re: ipsec impact on performance
Date: Thu, 03 Dec 2015 14:33:28 -0500 (EST)
Message-ID: <20151203.143328.1246663523839158336.davem@davemloft.net>
References: <20151201175953.GC21252@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151201175953.GC21252@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 1 Dec 2015 12:59:53 -0500

> I instrumented iperf with and without ipsec, just using esp-null, 
> and 1 thread, to keep things simple. I'm seeing some pretty dismal 
> performance numbers with ipsec, and trying to think of ways to
> improve this. Here are my findings, please share feedback.

Doesn't skb_cow_data() contribute significantly to the ESP base cost,
especially for TCP packets?

I mean, we're copying every TCP data frame.

If this is the case, even with GSO/whatever offloads, I expect that
performance will be roughly halfed.
