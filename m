From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH V2 5/7] sctp: use limited socket backlog
Date: Wed, 03 Mar 2010 09:36:21 -0500
Message-ID: <4B8E73E5.1030105@hp.com>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com> <1267605389-7369-2-git-send-email-yi.zhu@intel.com> <1267605389-7369-3-git-send-email-yi.zhu@intel.com> <1267605389-7369-4-git-send-email-yi.zhu@intel.com> <1267605389-7369-5-git-send-email-yi.zhu@intel.com> <4B8E6DD0.1020603@hp.com> <DA586906BA1FFC4384FCFD6429ECE860A45A699B@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sridhar Samudrala <sri@us.ibm.com>
To: "Zhu, Yi" <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:43670 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754363Ab0CCOgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:36:23 -0500
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860A45A699B@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Zhu, Yi wrote:
> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
> 
>> I think this will result in a double-free of the skb, because sctp_chunk_free
>> attempts to free the skb that's been assigned to the chunk.  You can set the skb
>> to NULL to get around that.
> 
> Ah, I missed that. Thanks!
> 
> <...>
> 
>> You also leak the ref counts here since now it's possible to not add a packet to
>> the backlog queue.  That means you'll take refs, but never drop them because
>> the receive routing will never run.
> 
> Good catch. I'll fix it.
> 
> BTW, does the current backlog limit (sysctl_rmem_default[1] << 1) enough for sctp?
> I noticed the sysctl_sctp_rmem[1] is set to 373500 in my box.
> 

sctp uses the same algorithm as TCP to figure out the memory values.
I guess the issue with using the smaller value that it would be possible to
queue more the socket receive buffer then to the backlog.  Thus backlog would
start dropping packets even though receive buffer would still accept them.

-vlad

> Thanks,
> -yi
> 
