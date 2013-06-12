From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] skbuff: Update truesize in pskb_expand_head
Date: Wed, 12 Jun 2013 02:16:58 -0700
Message-ID: <1371028618.3252.57.camel@edumazet-glaptop>
References: <1371027934-1955-1-git-send-email-david.wiltshire@gmx.com>
	 <1371027934-1955-2-git-send-email-david.wiltshire@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nsujir@broadcom.com,
	mchan@broadcom.com, rmody@brocade.com, jcliburn@gmail.com,
	chris.snook@gmail.com, jeffrey.t.kirsher@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	cooldavid@cooldavid.org, linux-driver@qlogic.com,
	linux-wimax@intel.com, wimax@linuxwimax.org,
	linux-wireless@vger.kernel.org, viro@zeniv.linux.org.uk,
	eparis@redhat.com, edumazet@google.com, dev@openvswitch.org,
	jhs@mojatatu.com
To: Dave Wiltshire <david.wiltshire@gmx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371027934-1955-2-git-send-email-david.wiltshire@gmx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-12 at 19:05 +1000, Dave Wiltshire wrote:
> Some call sites to pskb_expand_head subsequently update the skb truesize
> and others don't (even with non-zero arguments). This is likely a memory
> audit leak. Fixed this up by moving the memory accounting to the
> skbuff.c file and removing it from the calling sites.
> 
> Signed-off-by: Dave Wiltshire <david.wiltshire@gmx.com>
> ---
>  drivers/net/wireless/mwl8k.c |    1 -
>  kernel/audit.c               |    2 --
>  net/core/skbuff.c            |    1 +
>  net/netlink/af_netlink.c     |    3 +--
>  net/wireless/util.c          |    2 --
>  5 files changed, 2 insertions(+), 7 deletions(-)

Ouch.

Sorry, you cannot do that.

skb->truesize is really complex, because there is a strong relation
between skb->truesize and memory accounting on sockets.

So pskb_expand_head() should not touch skb->truesize.

Only callers can do that when needed, and if possible.

An example of very careful truesize manipulation can be found in
tcp_tso_segment()
