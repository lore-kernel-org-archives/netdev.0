From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH next 0/30] Passing net through the netfilter hooks
Date: Thu, 17 Sep 2015 17:24:37 -0500
Message-ID: <876138wuoq.fsf@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<55FAEAAC.1070302@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <55FAEAAC.1070302@6wind.com> (Nicolas Dichtel's message of "Thu,
	17 Sep 2015 18:30:36 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 16/09/2015 02:59, Eric W. Biederman a =C3=A9crit :
>>
>> My primary goal with this patchset and it's follow ups is to cleanup=
 the
>> network routing paths so that we do not look at the output device to
>> derive the network namespace.  My plan is to pass the network namesp=
ace
>> of the transmitting socket through the output path, to replace code =
that
>> looks at the output network device today.  Once that is done we can =
have
>> routes with output devices outside of the current network namespace.
>> Which should allow reception and transmission of packets in network
>> namespaces to be as fast as normal packet reception and transmission
>> with early demux disabled, because it will same code path.
>>
>> Once skb_dst(skb)->dev is a little better under control I think it w=
ill
>> also be possible to use rcu to cleanup the ancient hack that sets
>> dst->dev to loopback_dev when a network device is removed.
>>
>> The work to get there is a series of code cleanups.  I am starting w=
ith
>> passing net into the netfilter hooks and into the functions that are
>> called after the netfilter hooks.  This removes from netfilter the
>> need to guess which network namespace it is working on.
>>
>> To get there I perform a series of minor prep patches so the big cha=
nges
>> at the end are possible to audit without getting lost in the noise. =
 In
>> particular I have a lot of patches computing net into a local variab=
le
>> and then using it through out the function.
>>
>> So this patchset encompases removing dead code, sorting out the _sk
>> functions that were added last time someone pushed a prototype chang=
e
>> through the post netfilter functions.  Cleaning up individual functi=
ons
>> use of the network namespace.  Passing net into the netfilter hooks.
>> Passing net into the post netfilter functions.  Using state->net in
>> the netfilter code where it is available and trivially usable.
> LGTM (except some minor comments).
>
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Thanks for review.  I have added an extra patch for the missing blank
lines that are still missing after the entire series.  As they affect
neither code correctness nor bisectability I don't think there is any
point respinning the indivdual patches.

Eric
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
