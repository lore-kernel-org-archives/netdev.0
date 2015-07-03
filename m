From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 6/6] net_sched: act: remove spinlock in fast
 path
Date: Fri, 03 Jul 2015 07:07:27 -0400
Message-ID: <55966CEF.3000406@mojatatu.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-7-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>,
	Gregoire Baron <baronchon@n7mm.org>,
	Jiri Pirko <jiri@resnulli.us>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36060 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840AbbGCLHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 07:07:30 -0400
Received: by igrv9 with SMTP id v9so114915837igr.1
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 04:07:29 -0700 (PDT)
In-Reply-To: <1435842455-30501-7-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/15 09:07, Eric Dumazet wrote:
> Final step for gact RCU operation :
>
> 1) Use percpu stats
> 2) update lastuse only every clock tick
> 3) Remove spinlock acquisition, as it is no longer needed.
>
> Since this is the last contended lock in packet RX when tc gact is used,
> this gives impressive gain.
>
> My host with 8 RX queues was handling 5 Mpps before the patch,
> and more than 10 Mpps after patch.
>
> Tested:
>
> On receiver :
> IP=ip
> TC=tc
> dev=eth0
>
> $TC qdisc del dev $dev ingress 2>/dev/null
> $TC qdisc add dev $dev ingress
> $TC filter del dev $dev root pref 10 2>/dev/null
> $TC filter del dev $dev pref 10 2>/dev/null
> tc filter add dev $dev est 1sec 4sec parent ffff: protocol ip prio 1 \
> 	u32 match ip src 7.0.0.0/8 flowid 1:15 action drop
>
> Sender sends packets flood from 7/8 network
>

Very nice Eric;-> thanks.
So now basic accept/drop should be flying ;->
Other really low hanging fruit is act_csum, vlan and skbedit.
CCing the respective authors.

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
