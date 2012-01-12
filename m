From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: decrement memcg jump label when limit, not usage,
 is changed
Date: Thu, 12 Jan 2012 12:28:16 -0800 (PST)
Message-ID: <20120112.122816.1727420253535508242.davem@davemloft.net>
References: <1326370566-4286-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	cgroups@vger.kernel.org
To: glommer@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326370566-4286-1-git-send-email-glommer@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer@parallels.com>
Date: Thu, 12 Jan 2012 16:16:06 +0400

> The logic of the current code is that whenever we destroy
> a cgroup that had its limit set (set meaning different than
> maximum), we should decrement the jump_label counter.
> Otherwise we assume it was never incremented.
> 
> But what the code actually does is test for RES_USAGE
> instead of RES_LIMIT. Usage being different than maximum
> is likely to be true most of the time.
> 
> The effect of this is that the key must become negative,
> and since the jump_label test says:
> 
>         !!atomic_read(&key->enabled);
> 
> we'll have jump_labels still on when no one else is
> using this functionality.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>

Applied, thanks.
