From: Brian Haley <brian.haley@hpe.com>
Subject: Re: [Question/Bug] Should the priority of ip rule be unique?
Date: Mon, 11 Jan 2016 18:01:49 -0500
Message-ID: <5694345D.4040809@hpe.com>
References: <201601080632.u086WOPd003565@d23av04.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Hong Hui Xiao <xiaohhui@cn.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:27113 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759679AbcAKXBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 18:01:52 -0500
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com [15.217.128.51])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 1A4A03657
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 23:01:52 +0000 (UTC)
In-Reply-To: <201601080632.u086WOPd003565@d23av04.au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2016 01:32 AM, Hong Hui Xiao wrote:
> Hi,
>
>  From the man page of ip rule at [1], it says that "Each rule should have
> an explicitly set unique priority value." It is reasonable to have unique
> priority for ambiguous rules.
> But I have a set of unambiguous ip rules, do I still need to set the
> priority of to be unique? In practice, I can set ip rules with duplicated
> priority, and things works as expected. I want to confirm with iproute
> developers if this is a support usecase. If so, the information in man
> page may need updates.
>
> 5000: from all fwmark 0x4000000/0xffff0000 lookup table0
> 5000: from all fwmark 0x4010000/0xffff0000 lookup table1
> 5000: from all fwmark 0x4020000/0xffff0000 lookup table2
> 5000: from all fwmark 0x4030000/0xffff0000 lookup table3
>
>
> [1] http://man7.org/linux/man-pages/man8/ip-rule.8.html (search for
> "unique")

No, you shouldn't need to set the priority in this case as each rule is unique. 
  From reading earlier in the man page, and looking at the code, the rules are 
ordered and scanned in order of decreasing priority, with a lower priority being 
higher.  In the case of rules with the same priority they are ordered based on 
the order in which they were added to the kernel.

So I guess the man page could be tweaked a little, given "should" seems to 
follow the liberal IANA meaning of recommended, but not required.

-Brian
