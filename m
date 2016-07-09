From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ppp: defer netns reference release for ppp channel
Date: Fri, 08 Jul 2016 23:47:54 -0400 (EDT)
Message-ID: <20160708.234754.1545620882859351577.davem@davemloft.net>
References: <1467781956-2229-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matt.Bennett@alliedtelesis.co.nz,
	paulus@samba.org, linux-ppp@vger.kernel.org, g.nault@alphalink.fr,
	gorcunov@openvz.org
To: xiyou.wangcong@gmail.com
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1467781956-2229-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  5 Jul 2016 22:12:36 -0700

> Matt reported that we have a NULL pointer dereference
> in ppp_pernet() from ppp_connect_channel(),
> i.e. pch->chan_net is NULL.
> 
> This is due to that a parallel ppp_unregister_channel()
> could happen while we are in ppp_connect_channel(), during
> which pch->chan_net set to NULL. Since we need a reference
> to net per channel, it makes sense to sync the refcnt
> with the life time of the channel, therefore we should
> release this reference when we destroy it.
> 
> Fixes: 1f461dcdd296 ("ppp: take reference on channels netns")
> Reported-by: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: linux-ppp@vger.kernel.org
> Cc: Guillaume Nault <g.nault@alphalink.fr>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable.
