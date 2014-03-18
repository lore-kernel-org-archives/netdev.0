From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 3/3] bonding: convert pr_xxx() to
 pr_xxx_ratelimited() for arp interval
Date: Tue, 18 Mar 2014 04:14:22 -0700
Message-ID: <1395141262.2812.22.camel@joe-AO722>
References: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com>
	 <1395139433-19576-4-git-send-email-dingtianhong@huawei.com>
	 <1395140499.2812.19.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0050.hostedemail.com ([216.40.44.50]:37532 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755172AbaCRLOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 07:14:35 -0400
In-Reply-To: <1395140499.2812.19.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-18 at 04:01 -0700, Joe Perches wrote:
> On Tue, 2014-03-18 at 18:43 +0800, Ding Tianhong wrote:
> > The debug log in the arp interval should be rate limited, otherwise would
> > occur spam the log, so convert them.
[]
> Another way to do this is to use the
> more global net_ratelimit() before
> each existing pr_<level>.
> 
> Not suggesting one or the other is
> right or wrong here, it's just an option.

Another option is to use the net_<level>_ratelimited
functions, but I'm not sure these are used much
outside of net/.

> > diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> 
> > @@ -2131,32 +2131,33 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
> >  {
> >  	struct sk_buff *skb;
> >  
> > -	pr_debug("arp %d on slave %s: dst %pI4 src %pI4\n",
> > -		 arp_op, slave_dev->name, &dest_ip, &src_ip);
> > +	pr_debug_ratelimited("arp %d on slave %s: dst %pI4 src %pI4\n",
> > +			     arp_op, slave_dev->name, &dest_ip, &src_ip);
> 
> 	if (net_ratelimit())
> 		pr_debug(etc...)

or

	net_dbg_ratelimited(etc...)
