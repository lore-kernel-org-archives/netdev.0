From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] if_bridge: fix conflict with glibc
Date: Wed, 10 Dec 2014 20:44:53 -0500 (EST)
Message-ID: <20141210.204453.2032479274891251801.davem@davemloft.net>
References: <20141209214122.76b15851@urahara>
	<20141210.133417.152985082992875227.davem@davemloft.net>
	<20141210155745.3d375230@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.0xf0@gmail.com, f.fainelli@gmail.com,
	xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933315AbaLKBo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 20:44:56 -0500
In-Reply-To: <20141210155745.3d375230@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 10 Dec 2014 15:57:45 -0800

> On Wed, 10 Dec 2014 13:34:17 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> No, we really want to incluse the linux/in6.h header, as that's where all
>> the special GLIBC CPP checks are, such as:
>> 
>> #if __UAPI_DEF_IN6_ADDR_ALT
>> 
>> Please research how we have resolved the conflict between GLIBC and the
>> kernel's exported headers.  We really need to use linux/in6.h for all of
>> this to work.
>> 
>> I understand that it is upsetting that iproute2 stopped building for you,
>> but I'd like to kindly ask that you look more deeply into this and think
>> more longer term, rather than having a knee jerk reaction and looking for
>> quick fixes.
> 
> I don't have the time to understand the intricacies of glibc headers.
> The problem is that Gcc warns about duplicate definitions in headers;
> this is a useful warning and not something that I want to disable.
> Hacks with #undef seem to be heading the wrong way.

GLIBC and the kernel have unconditionally defined various types in
their copies of in.h, and the only way to resolve this moving forward
is to have some communication between the two so we can know who is
in fact in charge of instantianting the type.

The new defines, such as __UAPI_DEF_IN6_ADDR_ALT, are that new
mechanism.
