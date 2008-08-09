From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem
 with fpu state changes
Date: Fri, 08 Aug 2008 18:59:08 -0700
Message-ID: <489CF9EC.5050109@zytor.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com> <20080809014925.GA26529@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, viro@ZenIV.linux.org.uk,
	vegard.nossum@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:59488 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbYHICEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 22:04:15 -0400
In-Reply-To: <20080809014925.GA26529@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Aug 08, 2008 at 12:01:15PM -0700, H. Peter Anvin wrote:
>> It's technically overkill, if (and only if!) these instructions don't 
>> actually touch the SSE state (most likely they're using the SSE 
>> pipeline, and need this stuff to deal with power management issues.)
> 
> Yes the PadLock uses the SSE pipeline, but doesn't touch any
> of the state.

And yet it requires all the settings that goes along with holding the 
SSE state.  Really crap design, unfortunately.

>> However, overkill is a good way to make sure something is dead. 
>> Applying the patch will make sure we fix the regression, and we can 
>> worry about optimizing this further post-2.6.27.
> 
> Do we really need the FPU changes right now? I'd prefer for that
> to be backed out until a proper solution is found.  Disabling
> preemption around crypto is really bad for scheduling latency.

I hate to say it, but given the relative marketshare, we should disable 
Padlock instead.

This is part of the pain of being a minority architecture.

	-hpa

