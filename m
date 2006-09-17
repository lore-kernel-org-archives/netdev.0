From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [RFT] sky2 vs iptables
Date: Sat, 16 Sep 2006 23:01:46 -0400
Message-ID: <450CBA9A.4040705@gentoo.org>
References: <44FE2618.3010705@gentoo.org> <20060906141651.116aa758@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcclung@nebrwesleyan.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:18858 "EHLO
	smtp131.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1750997AbWIQDCq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Sep 2006 23:02:46 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060906141651.116aa758@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Tue, 05 Sep 2006 21:36:24 -0400
> Daniel Drake <dsd@gentoo.org> wrote:
>> There's a strange sky2 bug on the Gentoo bugzilla:
>> http://bugs.gentoo.org/show_bug.cgi?id=136508
>>
>> sky2 seems to work OK, but breaks as soon as the iptables ruleset is 
>> loaded. Nothing can be pinged, etc.
>>
>> Can someone try and reproduce this? The iptables rule script has been 
>> uploaded here:
>> http://bugs.gentoo.org/attachment.cgi?id=95694&action=view
>>
>> The very last command in that file is the one which produces an error 
>> and stops everything working:
>>
>> 	iptables: Unknown error 18446744073709551615
>>
>> Apparently a sky2 null deref has also been seen at this point, although 
>> I don't have further details on that.
> 
> It might be an artifact of the way sky2 was allocating receive buffers.
> Bridge-netfilter was assuming header space in the buffer, and would corrupt
> other memory, maybe iptables is assuming as well. This makes sky2
> use dev_alloc_skb that reserves space.
> -----------------------
> Subject: sky2: use dev_alloc_skb for receive buffers

Unfortunately the problem still exists with this patch. Any other ideas?

Daniel
