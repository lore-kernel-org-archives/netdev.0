From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Tue, 13 Jul 2010 15:19:43 +0200
Message-ID: <20100713131942.GA2641@sortiz-mobl>
References: <20100713001115.GA3751@sortiz-mobl>
 <alpine.LSU.2.01.1007130751360.19472@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Luciano Coelho <luciano.coelho@nokia.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.01.1007130751360.19472@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan,

On Tue, Jul 13, 2010 at 07:56:31AM +0200, Jan Engelhardt wrote:
> 
> On Tuesday 2010-07-13 02:11, Samuel Ortiz wrote:
> >
> >The userspace notification Xtables target sends a netlink notification
> >whenever a packet hits the target. Notifications have a label attribute
> >for userspace to match it against a previously set rule. The rules also
> >take a --all option to switch between sending a notification for all
> >packets or for the first one only.
> >Userspace can also send a netlink message to toggle this switch while the
> >target is in place. This target uses the nefilter netlink framework.
> 
> Would it not make sense to modify that module?
> Sounds an awful lot like NFQUEUE without passing the payload :)
yes, except for the payload, the missing "send one" packet toggle, and the
verdict we'd have to send back, it's almost identical ;)

What I'm trying to achieve with this target is a simple way to send a
userspace notification to userspace, without having to define a complex set of
rules, matches and having to pass some initial netlink message to set the
target properly (to avoid the payload passing in the NFLOG case).


> >+++ b/net/netfilter/xt_NFNOTIF.c
> >+struct nfnotif_tg {
> >+	struct list_head entry;
> >+	struct work_struct work;
> >+
> >+	char *label;
> >+	__u8 all_packets;
> >+	struct net *net;
> >+
> >+	__u8 send_notif;
> >+
> >+	unsigned int refcnt;
> >+};
> 
> Has unnecessary padding holes.

Right, I will send a v2 later today.

Thanks for your comments and review.

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
