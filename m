From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 2/2] net: Introduce possible_net_t
Date: Thu, 12 Mar 2015 11:33:21 -0500
Message-ID: <87y4n241m6.fsf@x220.int.ebiederm.org>
References: <20150311.215553.1544350193194225837.davem@davemloft.net>
	<1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150311.232940.1345045254716776224.davem@davemloft.net>
	<87oany7tha.fsf_-_@x220.int.ebiederm.org>
	<874mpq7tbf.fsf_-_@x220.int.ebiederm.org>
	<1426135075.11398.144.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	salo@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:60663 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489AbbCLQhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:37:03 -0400
In-Reply-To: <1426135075.11398.144.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 11 Mar 2015 21:37:55 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Wed, 2015-03-11 at 23:06 -0500, Eric W. Biederman wrote:
>> Having to say
>> > #ifdef CONFIG_NET_NS
>> > 	struct net *net;
>> > #endif
>> 
>> in structures is a little bit wordy and a little bit error prone.
>> 
>> Instead it is possible to say:
>> > typedef struct {
>> > #ifdef CONFIG_NET_NS
>> >       struct net *net;
>> > #endif
>> > } possible_net_t;
>> 
>> And then in a header say:
>> 
>> > 	possible_net_t net;
>> 
>> Which is cleaner and easier to use and easier to test, as the
>> possible_net_t is always there no matter what the compile options.
>> 
>> Further this allows read_pnet and write_pnet to be functions in all
>> cases which is better at catching typos.
>> 
>> This change adds possible_net_t, updates the definitions of read_pnet
>> and write_pnet, updates optional struct net * variables that
>> write_pnet uses on to have the type possible_net_t, and finally fixes
>> up the b0rked users of read_pnet and write_pnet.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>> 
>> When I was testing this caught all three locations Eric Dumazet needed
>> to add write_pnet as compile errors with network namespaces enabled.
>
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
> Only concern is the typedef possible_net_t : It seems number of uses
> should be rather small, and we probably could use the "struct
> possible_net" instead, to please Linus ;)

possible_net_t is a machine word size type so it falls into the
exceptions for typedefs in those cases.   It won't fool you about
how big it is, or how costly it is to use.

Years ago I remember passing a similar type to functions and watching
how even the function arguments boiled away at compile time, when
network namespaces were disabled.

Eric
