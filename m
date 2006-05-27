From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bridge: fix locking and memory leak in br_add_bridge
Date: Fri, 26 May 2006 19:26:11 -0700 (PDT)
Message-ID: <20060526.192611.109883073.davem@davemloft.net>
References: <20060525161432.4cbc11ee@griffin.suse.cz>
	<20060525092331.54f14a57@dxpl.pdx.osdl.net>
	<20060526110806.1fa49fe1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7618
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751767AbWE0C0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 22:26:02 -0400
To: jbenc@suse.cz
In-Reply-To: <20060526110806.1fa49fe1@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Benc <jbenc@suse.cz>
Date: Fri, 26 May 2006 11:08:06 +0200

> On Thu, 25 May 2006 09:23:31 -0700, Stephen Hemminger wrote:
> > +		unregister_netdevice(dev);
> > + err:
> >  	rtnl_unlock();
> > +	if (ret)
> > +		free_netdev(dev);
> >  	return ret;
> 
> I don't think this is correct. netdev_run_todo calls dev->destructor
> which is set to free_netdev by br_dev_setup. So you're calling
> free_netdev on already freed device.

Right, we need a more correct version of this bug fix. :)

