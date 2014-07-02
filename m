From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 1/5] netns: allocate netns ids
Date: Wed, 02 Jul 2014 15:57:32 +0200
Message-ID: <53B40FCC.4050603@6wind.com>
References: <537327F1.4060603@6wind.com> <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com> <1404302346-4507-2-git-send-email-nicolas.dichtel@6wind.com> <53B40A15.3030603@cogentembedded.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:61698 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbaGBN5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 09:57:46 -0400
Received: by mail-wg0-f46.google.com with SMTP id y10so11239495wgg.17
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 06:57:44 -0700 (PDT)
In-Reply-To: <53B40A15.3030603@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/07/2014 15:33, Sergei Shtylyov a =E9crit :
> Hello.
>
> On 07/02/2014 03:59 PM, Nicolas Dichtel wrote:
>
>> With this patch, netns allocates ids for all netns. Each netns has i=
ts own list
>> of ids, it means that the id is valid only in the current netns.
>
>> For homogeneity, an id is also allocated for the netns owner itself.
>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> [...]
>
>> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
>> index 85b62691f4f2..2976864cef13 100644
>> --- a/net/core/net_namespace.c
>> +++ b/net/core/net_namespace.c
>> @@ -144,6 +144,30 @@ static void ops_free_list(const struct pernet_o=
perations
>> *ops,
>>       }
>>   }
>>
>> +static int net_eq_idr(int id, void *net, void *peer)
>> +{
>> +    return net_eq(net, peer) ? id : 0;
>> +}
>> +
>> +int net2id(struct net *net, struct net *peer)
>> +{
>> +    ASSERT_RTNL();
>> +    return idr_for_each(&(net)->netns_ids, net_eq_idr, (peer)) ? : =
-ENOENT;
>
>     I don't think the inner parens are needed, this is not a macro bo=
dy...
Right!
In fact, it was a macro at the beginning ;-)

>
>> +}
>> +
>> +struct net *get_net_from_netnsid(struct net *net, int id)
>> +{
>> +    struct net *peer;
>> +
>> +    rcu_read_lock();
>> +    peer =3D idr_find(&(net)->netns_ids, id);
>
>     Same here.
Same.

Thank you,
Nicolas
