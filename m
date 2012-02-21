From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [PATCH V2] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 22:03:57 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F96E52@ORSMSX106.amr.corp.intel.com>
References: <20120221215127.30280.30853.stgit@gitlad.jf.intel.com>
 <20120221.165750.2246668899195223381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56611 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752693Ab2BUWD7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 17:03:59 -0500
In-Reply-To: <20120221.165750.2246668899195223381.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 21, 2012 1:58 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH V2] rtnetlink: Fix problem with buffer allocation
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Tue, 21 Feb 2012 13:51:28 -0800
> 
> > Implement a new netlink attribute type IFLA_EXT_MASK.  The mask
> > is a 32 bit value that can be used to indicate to the kernel that
> > certain extended ifinfo values are requested by the user application.
> > At this time the only mask value defined is RTEXT_FILTER_VF to
> > indicate that the user wants the ifinfo dump to send information
> > about the VFs belonging to the interface.
> >
> > This patch fixes a bug in which certain applications do not have
> > large enough buffers to accommodate the extra information returned
> > by the kernel with large numbers of SR-IOV virtual functions.
> > Those applications will not send the new netlink attribute with
> > the interface info dump request netlink messages so they will
> > not get unexpectedly large request buffers returned by the kernel.
> >
> > Modifies the rtnl_calcit function to traverse the list of net
> > devices and compute the minimum buffer size that can hold the
> > info dumps of all matching devices based upon the filter passed
> > in via the new netlink attribute filter mask.  If no filter
> > mask is sent then the buffer allocation defaults to NLMSG_GOODSIZE.
> >
> > With this change it is possible to add yet to be defined netlink
> > attributes to the dump request which should make it fairly extensible
> > in the future.
> >
> > CC: stable@vger.kernel.org
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> 
> Applied, with the minor change suggested by Eric in that we can
> use the non-RCU list traversal in the calcit function because
> we hold the RTNL always when this is invoked.

Oh good, that saves me a bit of work.

> 
> Thanks!

Thanks for working with me on this.  I learned a lot about how netlink actually works during the process though at the obvious cost of taking longer to get it done than someone who is more familiar with the net core code than I am.  Valuable experience for me and hopefully it will set us up well for future development.

- Greg
