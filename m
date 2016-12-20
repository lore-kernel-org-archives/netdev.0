From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] netfilter: check duplicate config when initializing
 in ipt_CLUSTERIP
Date: Tue, 20 Dec 2016 19:14:28 +0800
Message-ID: <CADvbK_e=cOyhVzWbrPM6E135iqAOP5gPdaXCoUBK8HE-dop+Xg@mail.gmail.com>
References: <9b3e1f76b5670d33727e63b6e166ae416b0d65af.1481776300.git.lucien.xin@gmail.com>
 <20161220004803.GA14656@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161220004803.GA14656@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 8:48 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Thu, Dec 15, 2016 at 12:31:40PM +0800, Xin Long wrote:
>> @@ -185,6 +186,17 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
>>       atomic_set(&c->refcount, 1);
>>       atomic_set(&c->entries, 1);
>>
>> +     spin_lock_bh(&cn->lock);
>> +     if (__clusterip_config_find(net, ip)) {
>> +             spin_unlock_bh(&cn->lock);
>> +             kfree(c);
>> +
>> +             return NULL;
>> +     }
>
> This is going to result in ENOMEM error report to userspace on race,
> which can be confusing. Time for clusterip_config_init() to return
> PTR_ERR()?
will post v2 with PTR_ERR, thanks.

>
>> +
>> +     list_add_rcu(&c->list, &cn->configs);
>> +     spin_unlock_bh(&cn->lock);
>> +
>>  #ifdef CONFIG_PROC_FS
>>       {
>>               char buffer[16];
