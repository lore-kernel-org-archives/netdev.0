From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/3] net: Replace for_each_possible_cpu with
 for_each_online_cpu
Date: Mon, 08 Aug 2016 10:59:08 -0700 (PDT)
Message-ID: <20160808.105908.301414649577514579.davem@davemloft.net>
References: <1470651742-15195-1-git-send-email-hejianet@gmail.com>
	<1470651742-15195-3-git-send-email-hejianet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: hejianet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470651742-15195-3-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jia He <hejianet@gmail.com>
Date: Mon,  8 Aug 2016 18:22:21 +0800

> In PowerPC server with large number cpus, the loop index in smt=1 could be 
> reduced to 1/8 compared with smt=8.
> Thus cache misses can be reduced.

You can't do this, if cpus go down we still want to report the statistics
they collected while they were up.

So we must use the possible cpu list here.
