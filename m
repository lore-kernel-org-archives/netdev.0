From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 19:53:39 -0600
Message-ID: <5716E123.8040002@cumulusnetworks.com>
References: <20160418.214851.122286645854721047.davem@davemloft.net>
 <20160418.235207.395468709808133833.davem@davemloft.net>
 <1461060543.2766.20.camel@sipsolutions.net>
 <20160419.142324.1774057494079734967.davem@davemloft.net>
 <1461094901.2766.26.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, egrumbach@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38199 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbcDTBxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 21:53:44 -0400
Received: by mail-ig0-f170.google.com with SMTP id m9so25270802ige.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 18:53:43 -0700 (PDT)
In-Reply-To: <1461094901.2766.26.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/16 1:41 PM, Johannes Berg wrote:
> On Tue, 2016-04-19 at 14:23 -0400, David Miller wrote:
>>
>> I like this nlattr flag idea, it's opt-in and any tool can be updated
>> to use the new facility.
>
> Right.
>
>> I'd be willing the backport the nlattr flag bit change to all stable
>> releases as well.
>
> I'm not really convinced that helps much - tools still can't really
> rely on the kernel supporting it.
>
> One thing that might work is that a tool might say it only wants to
> support kernels that have this change (assuming we backport it to
> enough kernels etc.); in that case the tool could add some absolutely
> must-have information (like the IFINDEX or whatever, depends on the
> command) with the new flag, this would get rejected since unpatched
> kernels wouldn't understand the flag and wouldn't find that must-have
> information.
>
> Nevertheless, I think it's most reliable with new netlink commands that
> are known to be available only on kernels understand and treating the
> flag correctly.

The kernel can set a flag in the response that it acknowledges the new 
attribute/flag. I did that for filtering neigh dumps -- 21fdd092acc7.
