From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize
 skb before it enters the IP stack)
Date: Wed, 21 May 2014 20:51:14 +0200
Message-ID: <537CF5A2.3080401@pandora.be>
References: <537621AC.1060409@davidnewall.com> <5379FFFD.1050705@davidnewall.com> <20140519140119.GA24523@breakpoint.cc> <537A12EA.4060604@davidnewall.com> <20140519170915.GB24523@breakpoint.cc> <537A6E5C.6090602@pandora.be> <537C5A6C.3030809@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: David Newall <davidn@davidnewall.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xavier.telenet-ops.be ([195.130.132.52]:42545 "EHLO
	xavier.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbaEUSvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 14:51:21 -0400
In-Reply-To: <537C5A6C.3030809@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Newall schreef op 21/05/2014 9:49:
>> An alternative would be to make sure that the data pointed to by IPCB
>> and BR_INPUT_SKB_CB don't overlap. If this were the case, we could
>> indeed just revert the commit that was referred to.
>
> They are identical spaces, but you imply a good point: the cb area is
> possibly being used, simultaneously, for two, incompatible purposes. Yet
> another argument for divorcing bridge of ip logic.

There's no reason why they should overlap in the cb: it's 48 bytes big, 
so big enough to hold both struct br_input_skb_cb and struct 
inet_skb_parm. The original problem was introduced when BR_INPUT_SKB_CB 
was introduced (around Feb 27, 2010), so fixing BR_INPUT_SKB_CB seems 
most appropriate to me.
As for your other remark: as I've said before, if you don't like 
bridge-netfilter then don't compile it into your kernel.

Bart
