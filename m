From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC V2 PATCH] rtnetlink: Fix problem with buffer allocation
Date: Mon, 13 Feb 2012 09:28:51 -0800
Message-ID: <20120213092851.61a3d1b1@nehalam.linuxnetplumber.net>
References: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51564 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755181Ab2BMR2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 12:28:55 -0500
In-Reply-To: <20120212191342.1458.70498.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Feb 2012 11:13:42 -0800
Greg Rose <gregory.v.rose@intel.com> wrote:

> Implement a new nlattr type IFLA_EXT_MASK.  The mask is a 32 bit
> value that can be used to indicate to the kernel that certain
> extended ifinfo values are requested by the user application.
> At this time the only mask value created is RTEXT_FILTER_VF to
> indicate that the user wants the ifinfo dump to send information
> about the VFs belonging to the interface.
> 
> I have kept the NLM_F_EXT nlmsg_flags bit to indicate to the kernel
> that the extended ifinfo dump filter mask is present.  It does not
> act as the filter itself which has changed since the first submission
> of this RFC.  Older versions of user applications won't set this
> flag which should fix the problem of some applications not allocating
> a large enough buffer for all the extended interface information.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>

Is u32 going to be enough in next 5 years?
Since it is TLV value it should work with bigger value;
could you try sending a oversize attribute and code kernel to ignore
bits it doesn't understand?
