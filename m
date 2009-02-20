From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/7] net: add FCoE offload support through net_device
Date: Fri, 20 Feb 2009 15:27:44 -0800
Message-ID: <20090220152744.6ce9b9de@s6510>
References: <20090219194734.22270.8445.stgit@zychengdu.jf.intel.com>
	<20090219194949.22270.40834.stgit.yi.zou@intel.com>
	<20090219132420.4b0dfc09@extreme>
	<7C88852EF6F99F4EB538472FCFEBE2222427B83D@orsmsx509.amr.corp.intel.com>
	<7C88852EF6F99F4EB538472FCFEBE2222427BC8F@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Zou, Yi" <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60864 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774AbZBTX2b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2009 18:28:31 -0500
In-Reply-To: <7C88852EF6F99F4EB538472FCFEBE2222427BC8F@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Feb 2009 15:21:42 -0800
"Zou, Yi" <yi.zou@intel.com> wrote:

> >>On Thu, 19 Feb 2009 12:49:49 -0700
> >>Yi Zou <yi.zou@intel.com> wrote:
> >>
> >>> This adds a "struct net_fcoe_ops *fcoe_ops" to net_device struct so
> >>any
> >>> network adapter driver can provide Fiber Channle over Ethernet (FCoE)
> >>offload
> >>> support through net_device. The fcoe_ops is only available when FCoE
> >>is
> >>> enabled in kernel as built-in or module driver.
> >>>
> >>> Signed-off-by: Yi Zou <yi.zou@intel.com>
> >>
> >>Rather than adding another _ops structure please add to existing
> >>netdevice_ops. You don't need the flags that way. If netdevice_ops
> >>has fcoe_setup, then device can do it...
> >The comments in struct net_device_ops says for management hooks, if
> >that's an ok place for net_fcoe_ops, then, I am all for it.
> >
> >Thanks.
> >
> >yi
> 
> Hi, Stephen,
> Regarding your comment about adding net_fcoe_ops to net_device_ops,
> the net_fcoe_ops contains function pointers ad well as data members,
> where net_device_ops seems to me is the placeholder only for function
> pointers. So I think it is still better to still leave
> the net_fcoe_ops to net_device. Let me know what you think.
> 
> Thanks,
> yi

Data members go in net_device (because they are per device instance).
Put fcoe stuff in net_device_ops.  Ideally, it should look like TSO
and GRO; with standard ethtool type config?
