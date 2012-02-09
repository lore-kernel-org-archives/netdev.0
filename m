From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Thu, 9 Feb 2012 16:25:31 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F86E01@ORSMSX106.amr.corp.intel.com>
References: <20120207223346.21320.89370.stgit@gitlad.jf.intel.com>
 <20120208.201018.97784090083485473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25357 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab2BIQZi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 11:25:38 -0500
In-Reply-To: <20120208.201018.97784090083485473.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 08, 2012 5:10 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Tue, 07 Feb 2012 14:33:46 -0800
> 
> > Add a 256 bit filter to allow the user to filter which VFs' info will
> > get displayed during the dump info request.  This is to fix a bug in
> > which a an info dump request on a device with many VFs would overflow
> > the recvmsg buffer which is allocated to max(8192, PAGE_SIZE).  A
> > complimentary patch to the iproute2 ip tool will allow the user to
> > set/clear individual VF filters.
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> 
> This isn't the idea.
> 
> I meant we have to add a generic u32 mask attribute to the GETLINK
> requests, and it's a mask of "features".  One feature bit would be for
> enabling the "VF" part of the dump, another bit would be for the
> macvlan source address lists that are being proposed, etc.  Any new
> auxiliarry information type we want to add to devide dumps, we have
> to add a feature bit for in this mask.
> 
> And then you can't just stop there, you have to update all of the
> logic related to min_ifinfo_dump_size to take into account the current
> request's mask state.
> 
> In fact this means you must get rid of the min_info_dump_size global
> variable altogether because the size is context dependent upon the
> mask configuration of the current dump request.

That will change the semantics to the 'ip link show' command quite a bit.  But OK, let me see what I can do with that.

- Greg
