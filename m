From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Thu, 25 Oct 2007 10:39:41 -0600
Message-ID: <m1y7dr5esy.fsf@ebiederm.dsl.xmission.com>
References: <47209317.8000802@bull.net> <4720A181.3060003@sw.ru>
	<4720AD20.5030902@bull.net> <m17ilb6xs9.fsf@ebiederm.dsl.xmission.com>
	<4720B1EE.8050507@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Denis V. Lunev" <den@sw.ru>, Pavel Emelianov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:50825 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762652AbXJYQlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 12:41:50 -0400
In-Reply-To: <4720B1EE.8050507@bull.net> (Benjamin Thery's message of "Thu, 25
	Oct 2007 17:10:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Thery <benjamin.thery@bull.net> writes:

> Eric W. Biederman wrote:
>> Benjamin Thery <benjamin.thery@bull.net> writes:
>> 
>>> Denis V. Lunev wrote:
>>>> The patch attached should help. The idea is simple. The "init" should be
>>>> called only once without NETNS. Period. No need for any lists.
>>> This is the kind of idea I had but I didn't think it could be 
>>> that simple. :) 
>>> Thanks Denis.
>> 
>> It isn't.
>> 
>>>> I'll resend it to Dave after the ACK.
>>> Tested on x86_64 with CONFIG_NET_NS=n and y. 
>>> It fixes the issue we observed.
>>>
>>> Acked-by: Benjamin Thery <benjamin.thery@bull.net>
>> 
>> Try rmmod.
>
> rmmod was part of my tests and it does work.
> I did:
>
> $ iptables --list
>
>   modules x_tables, ip_tables & iptable_filter are loaded
>   each calling register_pernet_subsys.
>
> $ rmmod iptable_filter ip_tables x_tables
>
>   No problem here
>
> $ iptables --list
>
>   To be sure I can load the modules again.

You haven't changed those modules to be mark struct
pernet_operations as __net_initdata have you?

If that is the case the symptoms you are seeing make sense.

Not doing the list walks helps when if it is only compiled in
kernel data structures that are removed.  However if it
is potentially modular data structures that are removed
the dereference of exit in unregister_pernet_subsys will also have
problems.

Eric
