From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Mon, 13 Feb 2012 18:24:40 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F8A898@ORSMSX106.amr.corp.intel.com>
References: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
 <20120213092851.61a3d1b1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:5013 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755662Ab2BMSYs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 13:24:48 -0500
In-Reply-To: <20120213092851.61a3d1b1@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Stephen Hemminger
> Sent: Monday, February 13, 2012 9:29 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
> 
> On Sun, 12 Feb 2012 11:13:42 -0800
> Greg Rose <gregory.v.rose@intel.com> wrote:
> 
> > Implement a new nlattr type IFLA_EXT_MASK.  The mask is a 32 bit
> > value that can be used to indicate to the kernel that certain
> > extended ifinfo values are requested by the user application.
> > At this time the only mask value created is RTEXT_FILTER_VF to
> > indicate that the user wants the ifinfo dump to send information
> > about the VFs belonging to the interface.
> >
> > I have kept the NLM_F_EXT nlmsg_flags bit to indicate to the kernel
> > that the extended ifinfo dump filter mask is present.  It does not
> > act as the filter itself which has changed since the first submission
> > of this RFC.  Older versions of user applications won't set this
> > flag which should fix the problem of some applications not allocating
> > a large enough buffer for all the extended interface information.
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> 
> Is u32 going to be enough in next 5 years?

I'm not very good at predicting the future.

;^)

> Since it is TLV value it should work with bigger value;
> could you try sending a oversize attribute and code kernel to ignore
> bits it doesn't understand?

That sounds like a good idea.  While I'm carving out some new space for the dump request message I might as well allocate some extra for future requirements.  I'll increase the size of the ext space array to something like 16 or 32 u32 sized words and increase the attribute length accordingly.  That should do for a long time I suppose.

First we'll see if the associated kernel patch is going to fly or not.

Thanks,

- Greg
