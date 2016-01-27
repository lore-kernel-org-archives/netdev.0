From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net:Add sysctl_tcp_sg_max_skb_frags
Date: Wed, 27 Jan 2016 07:15:02 -0800
Message-ID: <1453907702.20722.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <568F87AC.60405@oracle.com>
	 <1453900829-3384-1-git-send-email-hans.westgaard.ry@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"\"\"hannes@stressinduktion.org\"\"" <hannes@stressinduktion.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	Haakon Bugge <haakon.bugge@oracle.com>
To: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453900829-3384-1-git-send-email-hans.westgaard.ry@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-27 at 14:20 +0100, Hans Westgaard Ry wrote:
> Devices may have limits on the number of fragments in an skb they support.
> Current codebase uses a constant as maximum for number of fragments one
> skb can hold and use.
> When enabling scatter/gather and running traffic with many small messages
> the codebase uses the maximum number of fragments and may thereby violate
> the max for certain devices.
> The patch introduces a global variable as max number of fragments in
> scatter/gather.


Principle looks good, but we have to ask if other skb providers [1] will
add other sysctl, or if we could share a common one ?

If it is a common one, it should be /proc/sys/net/core/... instead
of /proc/sys/net/ipv4/tcp_....



Other providers include :

1) GRO stack
2) callers of sock_alloc_send_pskb(), alloc_skb_with_frags(),
sock_alloc_send_skb() ..

Thanks !
