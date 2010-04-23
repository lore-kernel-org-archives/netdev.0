From: Chris Wright <chrisw@redhat.com>
Subject: Re: eSwitch management
Date: Fri, 23 Apr 2010 09:23:07 -0700
Message-ID: <20100423162307.GI30693@x200.localdomain>
References: <C7F64614.2ADDF%scofeldm@cisco.com>
 <DD92D5A8-1ECC-4440-BE81-ABDCC6847021@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <scofeldm@cisco.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab0DWQXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Apr 2010 12:23:17 -0400
Content-Disposition: inline
In-Reply-To: <DD92D5A8-1ECC-4440-BE81-ABDCC6847021@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Anirban Chakraborty (anirban.chakraborty@qlogic.com) wrote:
> 
> On Apr 22, 2010, at 6:29 PM, Scott Feldman wrote:
> 
> > On 4/22/10 5:47 PM, "Scott Feldman" <scofeldm@cisco.com> wrote:
> > 
> >> On 4/22/10 4:16 PM, "Anirban Chakraborty" <anirban.chakraborty@qlogic.com>
> >> wrote:
> >> 
> >>> I am following the discussions on iovnl patch closely. While it is going to
> >>> take some time for iovnl patch to be reviewed and accepted, what would be the
> >>> interim approach to manage the eswitch in NIC? We need to add support in
> >>> qlcnic driver to configure the eswitch in our 10G NIC. Some of the things
> >>> that
> >>> we need to set to the switch are setting a port's VLAN, tx bandwidth etc. We
> >>> would like to set these parameters for a bunch of ports at the start of the
> >>> day and set it to the eswitch.
> >> 
> >> Are any of these settings covered in DCB?  (net/dcb/dcbnl.c).  Maybe you can
> >> get a start there?  Not sure not knowing your device requirements.
> > 
> > Or maybe the RTM_SETLINK IFLA_VF_* ops in include/linux/if_link.h?  Those
> > seem like what you're looking for.  I'm looking at moving iovnl here as well
> > for port-profile.
> 
> It looks like ifla_vf_info does contain most of the data set. But if I use it, what NETLINK protocol family should I use in my driver to receive netlink messages? Do I need to create a private protocol family?

No, you don't need to use netlink in your driver.  You just need to fill
in the relevant net_device_ops in your driver init.  Specifically:

 *      SR-IOV management functions.
 * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
 * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
 * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
 * int (*ndo_get_vf_config)(struct net_device *dev,
 *                          int vf, struct ifla_vf_info *ivf);

These are all operating on a VF indexed internally w/in the driver, so it's
a little cumbersome to use from userspace.

thanks,
-chris
