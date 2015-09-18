From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH next 0/14] netfilter: Stop guessing net
Date: Fri, 18 Sep 2015 13:15:14 -0500
Message-ID: <8737ybppal.fsf@x220.int.ebiederm.org>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
	<87pp1fpy1b.fsf@x220.int.ebiederm.org> <55FC3CB5.7040003@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: nicolas.dichtel@6wind.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <55FC3CB5.7040003@6wind.com> (Nicolas Dichtel's message of "Fri,
	18 Sep 2015 18:32:53 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 18/09/2015 17:06, Eric W. Biederman a =C3=A9crit :
>>
>> This is the next installment of my work to pass struct net through t=
he
>> output path so the code does not need to guess how to figure out whi=
ch
>> network namespace it is in, and ultimately routes can have output
>> devices in another network namespace.
>>
>> This round the changes focus on using nf_hook_state->net in the
>> netfilter functions, and not passing nf_hook_ops to the functions on=
 the
>> netfilter chains.
>>
>> Given the way per network namespace operations are implemented calle=
rs
>> can not rely on addresses or games with container_of.  None of the
>> netfilter hooks do but we should remove the temptation.  Plus removi=
ng
>> the extra parameter and the extra jump to get at values should reduc=
e
>> the number of cache line misses.
>>
>> At a practical matter this is the bulk of the work that other pieces=
 of
>> code in the netfilter stack will depend on.
> Great!
>
> LGTM.
> Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Grr.  A build bot failed to build this patchset and let me know.
Apparently a gremlin got in and disabled CONFIG_NET_ACT_CONNMARK in my
test config.

I will respin in a minute.

Eric

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
