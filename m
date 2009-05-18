From: David Miller <davem@davemloft.net>
Subject: Re: [IGB 2.6.29.3 bug] Re: WARNING at dev_disable_lro when
 enabling ip_forward
Date: Mon, 18 May 2009 16:41:37 -0700 (PDT)
Message-ID: <20090518.164137.261504026.davem@davemloft.net>
References: <20090518155714.0f1a3b20@nehalam>
	<20090518.160029.230477451.davem@davemloft.net>
	<20090518160804.571431d2@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergk@sergk.org.ua, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43955
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751832AbZERXlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 19:41:39 -0400
In-Reply-To: <20090518160804.571431d2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 18 May 2009 16:08:04 -0700

> On Mon, 18 May 2009 16:00:29 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> > @@ -2028,6 +2028,10 @@ static struct ethtool_ops igb_ethtool_ops = {
>> >  	.get_ethtool_stats      = igb_get_ethtool_stats,
>> >  	.get_coalesce           = igb_get_coalesce,
>> >  	.set_coalesce           = igb_set_coalesce,
>> > +#ifdef CONFIG_IGB_LRO
>> > +	.get_flags		= ethtool_op_get_flags,
>> > +	.set_flags		= ethtool_op_set_flags,
>> > +#endif
>> >  };
>> >  
>> >  void igb_set_ethtool_ops(struct net_device *netdev)
> 
> For get, the ifdef is superflous, but for set you don't want
> the user to turn LRO on if not configured.

Stephen's right, ->set_flags has to be ifdef protected.
