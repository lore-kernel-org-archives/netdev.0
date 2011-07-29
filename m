From: Greg Banks <gnb@fastmail.fm>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Sat, 30 Jul 2011 06:39:34 +1000
Message-ID: <D2301275-8653-41CB-BADB-E927CF00BDB0@fastmail.fm>
References: <1311876249.2346.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20110729164214.GI23194@fieldses.org> <1311962525.2873.6.camel@edumazet-laptop> <20110729180844.GA28947@fieldses.org>
Mime-Version: 1.0 (iPhone Mail 7C144)
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"bmarson@redhat.com" <bmarson@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110729180844.GA28947@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Sent from my iPhone

On 30/07/2011, at 4:08, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Jul 29, 2011 at 08:02:05PM +0200, Eric Dumazet wrote:
>> Le vendredi 29 juillet 2011 =C3=A0 12:42 -0400, J. Bruce Fields a =C3=
=A9cri=20
>> t :
>>> On Thu, Jul 28, 2011 at 08:04:09PM +0200, Eric Dumazet wrote:
>>>> Use NUMA aware allocations to reduce latencies and increase =20
>>>> throughput.
>>>>
>>>> sunrpc kthreads can use kthread_create_on_node() if pool_mode is
>>>> "percpu" or "pernode", and svc_prepare_thread()/svc_init_buffer() =
=20
>>>> can
>>>> also take into account NUMA node affinity for memory allocations.
>>> ...
>>>> @@ -662,14 +675,16 @@ svc_set_num_threads(struct svc_serv *serv, =20
>>>> struct svc_pool *pool, int nrservs)
>>>>        nrservs--;
>>>>        chosen_pool =3D choose_pool(serv, pool, &state);
>>>>
>>>> -        rqstp =3D svc_prepare_thread(serv, chosen_pool);
>>>> +        node =3D svc_pool_map_get_node(chosen_pool->sp_id);
>>>> +        rqstp =3D svc_prepare_thread(serv, chosen_pool, node);
>>>
>>> The only correct value for the third argument there is
>>> svc_pool_map_get_node(chosen_pool->sp_id), so let's have
>>> svc_prepare_thread() call that itself.
>>>
>>
>> I have no idea of what you mean ;)
>>
>> I need 'node' for the following kthread_create_on_node()
>
> Doh, of course--apologies.
>
>>> Seems OK otherwise.
>>>
>>> Any suggestions on how we should test this?
>>
>> I did tests on my machine, seems good.
>>
>> I checked that stacks were now correct using :
>> "echo t > /proc/sysrq-trigger"
>
> I was wondering more about good tests of nfsd's performance on numa;
> that might be more of a question for Greg.
>

To really show a big difference you need a much bigger box, or slower =20
NUMA interconnects than today's. You also want network cards locally =20
attached to each node and a metadata heavy (i.e. high rpc call rate) =20
load.

Greg.--
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
