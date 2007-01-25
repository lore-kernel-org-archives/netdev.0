From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC 1/31] net: Add net_namespace_type.h to allow for per network namespace variables.
Date: Thu, 25 Jan 2007 13:53:11 -0700
Message-ID: <m1bqkmygjs.fsf@ebiederm.dsl.xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
	<11697516331146-git-send-email-ebiederm@xmission.com>
	<20070125123017.1408941e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, <containers@lists.osdl.org>,
	<openib-general@openib.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:33237 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965577AbXAYUxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 15:53:54 -0500
In-Reply-To: <20070125123017.1408941e@freekitty> (Stephen Hemminger's message
	of "Thu, 25 Jan 2007 12:30:17 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> Can all this be a nop if a CONFIG option is not selected?

That is exactly what this infrastructure supports.
What you see is the version that comes into effect when
the CONFIG option is not selected.

>From using an empty structure to replace a pointer to make
that a NOP to most of the rest below.


>> diff --git a/include/linux/net_namespace_type.h
> b/include/linux/net_namespace_type.h
>> new file mode 100644
>> index 0000000..8173f59
>> --- /dev/null
>> +++ b/include/linux/net_namespace_type.h
>> @@ -0,0 +1,52 @@
>> +/* 
>> + * Definition of the network namespace reference type
>> + * And operations upon it.
>> + */
>> +#ifndef __LINUX_NET_NAMESPACE_TYPE_H
>> +#define __LINUX_NET_NAMESPACE_TYPE_H
>> +
>> +#define __pernetname(name) per_net__##name
>
> Code obfuscation, please don't do that

Single point of making the naming rules, better maintenance.
The basic point is that variables that come through this path
you should not access directly.  Tweaking the name enforces that
even in the compiled out state.

>> +typedef struct {} net_t;
>
> No typedef for this please.

Why.  That is conventially how we do opaque types in linux
when someone is doing something sophisticated.


You probably want to look down to patch 21 to see what the compiled
in version of these look like.

Eric
