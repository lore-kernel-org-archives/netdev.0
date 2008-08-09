From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem
 with fpu state changes
Date: Sat, 09 Aug 2008 09:05:50 -0700
Message-ID: <489DC05E.2080901@zytor.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:37695 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbYHIQMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 12:12:33 -0400
In-Reply-To: <20080809143727.GA30499@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Aug 08, 2008 at 04:11:21PM -0700, Suresh Siddha wrote:
>> With out the recent dynamic fpu allocation changes, while we don't see oops,
>> there is a possible race still present in older kernels(for example,
>> while kernel is using kernel_fpu_begin() in some optimized clear/copy
>> page and an interrupt/softirq happens which uses these padlock
>> instructions generating DNA fault).
> 
> No this wasn't a problem because kernel_fpu_begin clears TS and
> therefore we don't get faults on SSE instructions.
> 
> However, with your patch it will become a problem due to the
> fact that it wasn't designed to be nested.
> 

We're invoking this code from interrupt handlers?

	-hpa

