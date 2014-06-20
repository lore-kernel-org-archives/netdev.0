From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch net-next] veth: add netpoll support
Date: Fri, 20 Jun 2014 16:07:58 -0400
Message-ID: <20140620200758.GB18996@hmsreliant.think-freely.org>
References: <1403291878-4199-1-git-send-email-xiyou.wangcong@gmail.com>
 <53A48C12.8020104@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	s.priebe@profihost.ag, "David S. Miller" <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46691 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757583AbaFTUIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 16:08:04 -0400
Content-Disposition: inline
In-Reply-To: <53A48C12.8020104@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2014 at 11:31:30PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 06/20/2014 11:17 PM, Cong Wang wrote:
> 
> >It is trivial to add netpoll support to veth, since
> >it is not stacked device, we don't need to setup and cleanup
> >netpoll.
> 
> >Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> >Cc: "David S. Miller" <davem@davemloft.net>
> >Cc: Neil Horman <nhorman@tuxdriver.com>
> >Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> >---
> >diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> >index b4a10bc..03e781b 100644
> >--- a/drivers/net/veth.c
> >+++ b/drivers/net/veth.c
> >@@ -248,6 +248,13 @@ static void veth_dev_free(struct net_device *dev)
> >  	free_netdev(dev);
> >  }
> >
> >+#ifdef CONFIG_NET_POLL_CONTROLLER
> >+static void veth_poll_controller(struct net_device *dev)
> >+{
> >+	return;
> 
>    Not needed.
It is, a valid function poniter is how the stack determines if a given driver
supports netpoll. See the tun_poll_controller for another example
Neil

> 
> >+}
> >+#endif	/* CONFIG_NET_POLL_CONTROLLER */
> >+
> >  static const struct net_device_ops veth_netdev_ops = {
> >  	.ndo_init            = veth_dev_init,
> >  	.ndo_open            = veth_open,
> 
> WBR, Sergei
> 
> 
