From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [net-next PATCH] igb: remove skb_orphan calls
Date: Fri, 27 Feb 2009 08:39:30 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F283B712F@orsmsx501.amr.corp.intel.com>
References: <80769D7B14936844A23C0C43D9FBCF0F283B6220@orsmsx501.amr.corp.intel.com>
 <20090227031421.GA21036@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Ohly, Patrick" <patrick.ohly@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47360 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbZB0Qjd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 11:39:33 -0500
In-Reply-To: <20090227031421.GA21036@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Duyck, Alexander H <alexander.h.duyck@intel.com> wrote:
>> 
>> This patch was meant to be more general than just timestamping.  I
>> was just using timestamping as one example of where things can go
>> wrong due to the skb_orphan call.  The main problem is triggering
>> desctructors and removing the sk can cause multiple issues with any
>> custom use of the skb.  It is easiest to avoid those by not calling
>> skb_orphan in the first place.     
> 
> It doesn't matter what those custom uses are, what Dave was saying
> is that we're thinking of killing skb->sk before it even gets to
> the driver.  So even if such custom uses existed (which AFAIK do
> not), we'd been looking at killing them as well.

The fact is, if you are planning to kill it further up the stack, you can put that down as another reason for removing the call.  The timesync / killing skb->sk is a separate discussion that I don't know if I even really need to be involved in.  The patch doesn't break anything, and removes a call to skb_orphan that shouldn't really be there in the first place.

Thanks,

Alex

