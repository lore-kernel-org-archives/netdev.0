From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/8] fs/quota: use nla_put_u64_64bit()
Date: Tue, 26 Apr 2016 12:24:01 -0400 (EDT)
Message-ID: <20160426.122401.405766250705456167.davem@davemloft.net>
References: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
	<1461657978-13360-4-git-send-email-nicolas.dichtel@6wind.com>
	<20160426110848.GD27612@quack2.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	sd@queasysnail.net, johannes@sipsolutions.net,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	jack@suse.com, linux-kernel@vger.kernel.org, pshelar@nicira.com,
	dev@openvswitch.org, jhs@mojatatu.com, philipp.reisner@linbit.com,
	lars.ellenberg@linbit.com, drbd-dev@lists.linbit.com
To: jack@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160426110848.GD27612@quack2.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kara <jack@suse.cz>
Date: Tue, 26 Apr 2016 13:08:48 +0200

> On Tue 26-04-16 10:06:13, Nicolas Dichtel wrote:
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> 
> OK, so I somewhat miss a description of what will this do to the netlink
> message so that I can judge whether the change is fine for the userspace
> counterpart parsing these messages. AFAIU this changes the message format
> by adding a QUOTA_NL_A_PAD field before each 64-bit field which needs an
> alignment, am I guessing right? Thus when the userspace counterpart uses
> genlmsg_parse() it should just silently ignore these attributes if I read
> the documentation right. Did I understand this correctly?

All userspace components using netlink should always ignore attributes
they do not recognize in dumps.

This is one of the most basic principles of netlink.
