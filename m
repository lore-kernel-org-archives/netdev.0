From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 15:13:02 -0400
Message-ID: <451D703E.3020500@hp.com>
References: <36282A1733C57546BE392885C0618592015CF32C@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:10941 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161526AbWI2TNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 15:13:07 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C0618592015CF32C@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
>>>>While I don't see any explicit mention of it in the documentation or
>>>>your comments, I assume we would want a flow_out check for 
>>>>NetLabel here
>>>>as well?
>>>
>>> 
>>>I don't believe we do. By this time, the packet is or 
>>
>>should already be
>>
>>>carrying the CIPSO/NetLabel option which should already be 
>>
>>the right one
>>
>>>(derived from the socket or flow as appropriate), but you 
>>
>>would want to
>>
>>>audit the code to make sure. IOW, the label option in the 
>>
>>IP header should
>>
>>>already be reflecting the secmark on the skb. But again, 
>>
>>you may want to
>>
>>>audit the code to make sure.
>>
>>In the case above I am concerned about the situation where the
>>skb->secmark == 0 and there is a IPv4 option (i.e. it is NetLabel
>>labeled) on the packet.

It's unfortunate that you cut out the code in your reply.

> Where we initialize the secmark should be immaterial from the NetLabel
> point of view. The kernel mechanisms should assure that the IP option
> reflects the MLS portion (or a label in the SA range) elsewhere.

Yep, I agree.

> In any
> case, a flow_out check doesn't make sense since the IP option and the
> secmark are (should be) mirroring each other and there's in actuality
> no "flow out" happening; they are just 2 representation of the SAME label.

Well, reading the code I see that if the secmark is zero upon entering
the function you query the XFRM subsystem to query the SA label and set
the secmark accordingly, yes?  All I am suggesting is that we do the
same thing for NetLabel.

Please see the mail I sent earlier with the code in it to address James'
concerns, this has a proposed solution for the flow_out case.

> Your suggestion as to adjusting the secmark per the IP option might be
> fraught with danger since, in certain cases, I believe, you just return
> the incoming options in the outgoing packet (timewait, openreq, etc.?),
> and there's no assurance that that's a valid enough option that you can
> retrieve a sid with it, correct?

As implemented in the code snippets I sent earlier the generated
NetLabel SID would reflect the secmark as determined by the IPsec label
and the IP options on the packet.  I believe this is what we want as the
resulting secmark value would directly represent the security attributes
of the packet.

-- 
paul moore
linux security @ hp
