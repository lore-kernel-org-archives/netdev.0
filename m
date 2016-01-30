From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 5/6] net: mvneta: The mvneta_percpu_elect function
 should be atomic
Date: Fri, 29 Jan 2016 20:38:10 -0800 (PST)
Message-ID: <20160129.203810.1601035648854177084.davem@davemloft.net>
References: <1454084767-24715-1-git-send-email-gregory.clement@free-electrons.com>
	<1454084767-24715-6-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
	linux-arm-kernel@lists.infradead.org, alior@marvell.com,
	nadavh@marvell.com, mw@semihalf.com, linux@arm.linux.org.uk,
	w@1wt.eu
To: gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454084767-24715-6-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Fri, 29 Jan 2016 17:26:06 +0100

> @@ -370,6 +370,8 @@ struct mvneta_port {
>  	struct net_device *dev;
>  	struct notifier_block cpu_notifier;
>  	int rxq_def;
> +	/* protect  */
> +	spinlock_t lock;
>  
>  	/* Core clock */
>  	struct clk *clk;

Protect what?  This comment needs a lot of improvement.

Everyone knows a spinlock "protects" things, so if you aren't going
to actually describe what this lock protects, and in what contexts
the lock is used, you might as well not say anything at all.
