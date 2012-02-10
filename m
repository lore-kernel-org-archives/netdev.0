From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] rtnetlink: Fix problem with buffer allocation
Date: Fri, 10 Feb 2012 19:07:15 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F88CF8@ORSMSX106.amr.corp.intel.com>
References: <20120210150518.4002.85507.stgit@gitlad.jf.intel.com>
 <20120210.135151.754379087490167636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40660 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759760Ab2BJTHW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 14:07:22 -0500
In-Reply-To: <20120210.135151.754379087490167636.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, February 10, 2012 10:52 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC PATCH] rtnetlink: Fix problem with buffer allocation
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Fri, 10 Feb 2012 07:05:18 -0800
> 
> > +/*
> > + * Applications that set NLM_F_EXT have allocated
> > + * a 16K or larger buffer.
> > + * (Or they should have before using this flag)
> > + */
> > +#define NLM_F_EXT	0x800   /* Get extended interface info such as VFs
> */
> 
> This is not what I meant.
> 
> I meant to add a "netlink attribute" that gets passed in with GETLINK
> requests.  Which is a u32 set of flag bits, one bit for each extended
> feature.  So VF would get one bit.
> 
> Like "IFLA_EXT_MASK" or similar.
> 
> Then rtnl_getlink() would inspect the mask (using nla_get_32()), if
> present, and make this control what extended parts of the per-link
> dump are provided.

OK, sounds good.  How about I also add a field to indicate the application buffer size?

- Greg
