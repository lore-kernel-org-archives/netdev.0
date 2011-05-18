From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V4 PATCH] rtnetlink: Compute and store minimum ifinfo dump
 size
Date: Wed, 18 May 2011 15:35:58 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755018E321C21@orsmsx508.amr.corp.intel.com>
References: <20110518155410.28491.62723.stgit@gitlad.jf.intel.com>
 <20110518.180913.273729651812642114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50155 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365Ab1ERWgA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 18:36:00 -0400
In-Reply-To: <20110518.180913.273729651812642114.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, May 18, 2011 3:09 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> eric.dumazet@gmail.com
> Subject: Re: [RFC V4 PATCH] rtnetlink: Compute and store minimum ifinfo
> dump size
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Wed, 18 May 2011 08:54:11 -0700
> 
> > The message size allocated for rtnl info dumps was limited to a single
> > page.  This is not enough for additional interface info available with
> > devices that support SR-IOV.  Calculate the amount of data required so
> > the dump can allocate enough data to satisfy the request.
> >
> > V2 added the calcit function to the rtnl_register calls so that
> > dump functions could get the minimum dump allocation size if they
> > needed to.
> >
> > V3 leverages the fact that the netdev register function ends up
> > calling if_nlmsg_size.  We collect the minimum dump allocation size
> > there and keep it in a module static variable so that the calcit
> > function doesn't have to search for the device on every info dump.
> >
> > V4 fixes the title.
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> 
> This only works if someone does a plain GETLINK request on the largest
> space requiring device before the dump request happens.

It looked to me like rtmsg_ifinfo is called when each device is registered through register_netdevice() and rtmsg_ifinfo in turn calls the if_nlmsg_size function returning the ifinfo dump size for each device.  In my testing it looked like the proper maximum size was being set after I loaded the drivers for the SR-IOV capable devices.

Perhaps I missed something?  Is register_netdevice not always called before a device is used?

- Greg

