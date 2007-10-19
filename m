From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 0/4] Fix race between sk_filter reassign and sk_clone()
Date: Fri, 19 Oct 2007 11:37:02 +0400
Message-ID: <47185E9E.1030102@openvz.org>
References: <4715D9D2.8070102@openvz.org>	<20071017.212302.68039057.davem@davemloft.net>	<20071019022947.GA29560@lixom.net> <20071018.215521.28810637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54014 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761909AbXJSHhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 03:37:22 -0400
In-Reply-To: <20071018.215521.28810637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Olof Johansson <olof@lixom.net>
> Date: Thu, 18 Oct 2007 21:29:47 -0500
> 
>> So, looks like rcu_dereference() returned NULL. I don't know the
>> filter code at all, but it seems like it might be a valid case?
>> sk_detach_filter() seems to handle a NULL sk_filter, at least.
>>
>>
>> So, this needs review by someone who knows the filter, but it fixes the
>> problem for me:

Yes. The NULL filter is a valid case, when there are no
filters attached at all. So this fix is correct.

Thanks, Olof. Sorry, Dave :(

>>
>> Signed-off-by: Olof Johansson <olof@lixom.net>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

> I've applied this for now to my net-2.6 tree, thanks Olof
> for tracking this down.
> 
> Pavel please take a look at this and let me know if it should
> fixed in some other way.
> 
> Thanks!
> 

