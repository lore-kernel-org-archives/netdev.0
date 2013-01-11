From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next 09/15] e1000e: resolve checkpatch PREFER_PR_LEVEL
 warning
Date: Fri, 11 Jan 2013 18:05:06 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1843ABA7490@ORSMSX102.amr.corp.intel.com>
References: <1357899831-4168-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1357899831-4168-10-git-send-email-jeffrey.t.kirsher@intel.com>
 <1357923819.2327.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29641 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753754Ab3AKSF2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 13:05:28 -0500
In-Reply-To: <1357923819.2327.5.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Friday, January 11, 2013 9:04 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Allan, Bruce W; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 09/15] e1000e: resolve checkpatch PREFER_PR_LEVEL
> warning
> 
> On Fri, 2013-01-11 at 02:23 -0800, Jeff Kirsher wrote:
> > WARNING: Prefer netdev_info(netdev, ... then dev_info(dev, ...
> > then pr_info(...  to printk(KERN_INFO ...
> []
> > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> b/drivers/net/ethernet/intel/e1000e/netdev.c
> []
> > @@ -4300,9 +4300,8 @@ static void e1000_print_link_info(struct
> e1000_adapter *adapter)
> >  	u32 ctrl = er32(CTRL);
> >
> >  	/* Link status message must follow this format for user tools */
> > -	printk(KERN_INFO "e1000e: %s NIC Link is Up %d Mbps %s Duplex,
> Flow Control: %s\n",
> > -		adapter->netdev->name,
> > -		adapter->link_speed,
> > +	pr_info("e1000e: %s NIC Link is Up %d Mbps %s Duplex, Flow
> Control: %s\n",
> > +		adapter->netdev->name, adapter->link_speed,
> 
> Don't these changes break a user-space tool?
> 
> If not, please remove the comment above the pr_info()s
> and remove the unnecessary e1000e: prefixes.
> 
> > @@ -4521,8 +4520,8 @@ static void e1000_watchdog_task(struct
> work_struct *work)
> []
> >  			/* Link status message must follow this format */
> > -			printk(KERN_INFO "e1000e: %s NIC Link is Down\n",
> > -			       adapter->netdev->name);
> > +			pr_info("e1000e: %s NIC Link is Down\n",
> > +				adapter->netdev->name);
> 

Hmm, I'm not sure how that got past our testing even after I asked to check for
redundant instances of "e1000e".  This patch can be dropped and I will submit an
updated one but it will still have the "must follow this format for user tools" comment
since the user tools key off of "e1000e: <iface> NIC Link is ..." text.

Thanks,
Bruce.
