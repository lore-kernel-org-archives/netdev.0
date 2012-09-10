From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v2] Take care of xfrm policy when checking dst
 entries
Date: Mon, 10 Sep 2012 10:35:03 -0400
Message-ID: <504DFA97.7070509@gmail.com>
References: <20120907.144828.97793990734588625.davem@davemloft.net> <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55152 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113Ab2IJOfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 10:35:08 -0400
In-Reply-To: <1347283338-4249-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2012 09:22 AM, Nicolas Dichtel wrote:
> The goal of these patches is to fix the following problem: a session is
> established (TCP, SCTP) and after a new policy is inserted. The current
> code does not recalculate the route, thus the traffic is not encrypted.
>
> The patch propose to check flow_cache_genid value when checking a dst
> entry, which is incremented each time a policy is inserted or deleted.
>
> v2: use net->ipv4.rt_genid instead of flow_cache_genid (and thus save a test
>      in fast path). Also move it to net->rt_genid, to be able to use it for IPv6
>      too. Note that IPv6 will have one more test in fast path.
>
> Patches are tested with TCP and SCTP, IPv4 and IPv6.
>
> Comments are welcome.
>
> Regards,
> Nicolas
>

I am not sure this is right...  This has a side-effect that when an 
rt_cache_flush() is called, it invalidates IPv6 routes a well....

Its all fine and good do this when a new policy is added, but not when 
IPv4 routing table changes.

-vlad
