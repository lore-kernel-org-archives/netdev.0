From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igmp: remove useless (void) cast
Date: Mon, 03 Jun 2013 00:38:46 -0700 (PDT)
Message-ID: <20130603.003846.2026148588738043632.davem@davemloft.net>
References: <20130531184438.21966f63@nehalam.linuxnetplumber.net>
	<kobnip$gat$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab3FCHir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:38:47 -0400
In-Reply-To: <kobnip$gat$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sat, 1 Jun 2013 02:51:05 +0000 (UTC)

> On Sat, 01 Jun 2013 at 01:44 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
>> Back in the old Unix lint days, it was common to put (void) in front
>> of functions when return value was being ignored. Now this is considered
>> unnecessary, catch up with the fashion.
>>
> 
> None of the callers of ip_mc_leave_src() checks its return value, so I
> think we can just make it void.

So ip_mc_leave_src() calls ip_mc_del_src and all the call chains essentially
ignore the one error case that ip_mc_del_src() has, namely "!in_dev".

Most call chains validate that in_dev is not NULL before it ends up calling
ip_mc_del_src().

However, ip_mc_leave_group() is peculiar, it seems to expect that
sometimes "in_dev" can be NULL, and still signals -ENODEV when this
happens even though it still did all of the adjustments to the
socket's multicast group blobs.

Someone really needs to audit this code before we start just pretending
the error returns do not matter.

I'm not applying this patch for now, there are too many loose ends.

Thanks.
