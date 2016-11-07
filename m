From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] net: l2tp: fix L2TP_ATTR_UDP_CSUM
 attribute type
Date: Mon, 07 Nov 2016 13:08:45 -0500 (EST)
Message-ID: <20161107.130845.286540537414841421.davem@davemloft.net>
References: <20161104224838.7925-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, shankerwangmiao@gmail.com
To: asbjorn@asbjorn.st
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104224838.7925-1-asbjorn@asbjorn.st>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
Date: Fri,  4 Nov 2016 22:48:34 +0000

> L2TP_ATTR_UDP_CSUM is a flag, and gets read with
> nla_get_flag, but it is defined as NLA_U8 in
> the nla_policy.
> 
> It appears that this is only publicly used in
> iproute2, where it's broken, because it's used as
> a NLA_FLAG, and fails validation as a NLA_U8.
> 
> The only place it's used as a NLA_U8 is in
> l2tp_nl_tunnel_send(), but iproute2 again reads that
> as a flag, it's therefore always set. Fortunately
> it is never used for anything, just read.
> 
> CC: Miao Wang <shankerwangmiao@gmail.com>
> Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>

This is definitely the wrong way to go about this.

The kernel is everywhere and updating iproute2 is infinitely
easier for users to do than updating the kernel.

And in any event, once exported we really should never change
the API of anything shown to userspace like this.  Just because
you can't find a user out there doesn't mean it doesn't exist.

Please instead fix iproute2 to use u8 attributes for this.

Thanks.
