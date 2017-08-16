From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/3 v4] drivers: net: ethernet: qualcomm:
 rmnet: Initial implementation
Date: Wed, 16 Aug 2017 11:08:40 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0056B94@AcuExch.aculab.com>
References: <1502856953-30321-1-git-send-email-subashab@codeaurora.org>
        <1502856953-30321-4-git-send-email-subashab@codeaurora.org>
 <20170815.212414.71937112074428743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "fengguang.wu@intel.com" <fengguang.wu@intel.com>,
        "dcbw@redhat.com" <dcbw@redhat.com>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>
To: 'David Miller' <davem@davemloft.net>,
        "subashab@codeaurora.org" <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:63484 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdHPLIr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 07:08:47 -0400
In-Reply-To: <20170815.212414.71937112074428743.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 16 August 2017 05:24
> From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Date: Tue, 15 Aug 2017 22:15:53 -0600
> 
> > +static int rmnet_unregister_real_device(struct net_device *dev)
> > +{
> > +	int config_id = RMNET_LOCAL_LOGICAL_ENDPOINT;
> > +	struct rmnet_logical_ep_conf_s *epconfig_l;
> > +	struct rmnet_phys_ep_conf_s *config;
> > +
> > +	ASSERT_RTNL();
> > +
> > +	netdev_info(dev, "Removing device %s\n", dev->name);
> > +
> > +	if (!rmnet_is_real_dev_registered(dev))
> > +		return -EINVAL;
> > +
> > +	for (; config_id < RMNET_MAX_LOGICAL_EP; config_id++) {
> 
> This loop is so much harder to understand because you initialize
> the loop index several lines above the for() statement.  Just
> initialize it here at the beginning of the for() loop and deal
> with the fact that this will have to therefore be a multi-line
> for() statement the best you can.
...

One way to split the multi-line for() is to put the initialiser
on the immediately preceding line:
	config_id = RMNET_LOCAL_LOGICAL_ENDPOINT;
	for (; config_id < RMNET_MAX_LOGICAL_EP; config_id++) {

	David
