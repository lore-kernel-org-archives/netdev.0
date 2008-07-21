From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] arptables in netns for real
Date: Mon, 21 Jul 2008 21:03:21 +0400
Message-ID: <20080721170321.GA13486@martell.zuzino.mipt.ru>
References: <20080721162920.GD13264@martell.zuzino.mipt.ru> <alpine.LNX.1.10.0807211846210.21244@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, xemul@openvz.org, den@openvz.org,
	ebiederm@xmission.com, dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0807211846210.21244@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 21, 2008 at 06:47:22PM +0200, Jan Engelhardt wrote:
> On Monday 2008-07-21 18:29, Alexey Dobriyan wrote:
> >-			      int (*okfn)(struct sk_buff *))
> >+static unsigned int arpt_in_hook(unsigned int hook,
> >+				 struct sk_buff *skb,
> >+				 const struct net_device *in,
> >+				 const struct net_device *out,
> >+				 int (*okfn)(struct sk_buff *))
> > {
> >-	return arpt_do_table(skb, hook, in, out, init_net.ipv4.arptable_filter);
> >+	return arpt_do_table(skb, hook, in, out,
> >+			     dev_net(in)->ipv4.arptable_filter);
> >+}
> 
> What I dislike with this netns stuff is that you need to touch
> the ->ipv4. structure if you want to add new tables and there is
> no more way to dynamically add tables from 3rd party modules unless
> the admin loading them is fine with having them register against
> &init_net only.

Not exactly sure, if it's sufficient for you, you can use
net_assign_generic() infrastructure from module and not touch "struct net"
at all.

