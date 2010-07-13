From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: xtables: userspace notification target
Date: Tue, 13 Jul 2010 07:56:31 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007130751360.19472@obet.zrqbmnf.qr>
References: <20100713001115.GA3751@sortiz-mobl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Luciano Coelho <luciano.coelho@nokia.com>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100713001115.GA3751@sortiz-mobl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2010-07-13 02:11, Samuel Ortiz wrote:
>
>The userspace notification Xtables target sends a netlink notification
>whenever a packet hits the target. Notifications have a label attribute
>for userspace to match it against a previously set rule. The rules also
>take a --all option to switch between sending a notification for all
>packets or for the first one only.
>Userspace can also send a netlink message to toggle this switch while the
>target is in place. This target uses the nefilter netlink framework.

Would it not make sense to modify that module?
Sounds an awful lot like NFQUEUE without passing the payload :)

>+++ b/net/netfilter/xt_NFNOTIF.c
>+struct nfnotif_tg {
>+	struct list_head entry;
>+	struct work_struct work;
>+
>+	char *label;
>+	__u8 all_packets;
>+	struct net *net;
>+
>+	__u8 send_notif;
>+
>+	unsigned int refcnt;
>+};

Has unnecessary padding holes.
