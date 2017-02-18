From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] sctp: check duplicate node before inserting a new transport
Date: Sat, 18 Feb 2017 23:47:38 +0800
Message-ID: <CADvbK_dvJoEvmx1PvemxUS1090J1o=Gx3COPK7rdHT4Z1z27UQ@mail.gmail.com>
References: <ba2afff1b2cf9e0026a23dde02d207583efa3d83.1487320524.git.lucien.xin@gmail.com>
 <20170217.151907.1987368624831286456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:32775 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752324AbdBRPrj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 10:47:39 -0500
In-Reply-To: <20170217.151907.1987368624831286456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 18, 2017 at 4:19 AM, David Miller <davem@davemloft.net> wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Fri, 17 Feb 2017 16:35:24 +0800
>
>
>> +     list = rhltable_lookup(&sctp_transport_hashtable, &arg,
>> +                            sctp_hash_params);
>> +
>> +     rhl_for_each_entry_rcu(transport, tmp, list, node)
>> +             if (transport->asoc->ep == t->asoc->ep) {
>> +                     err = -EEXIST;
>> +                     goto out;
>> +             }
>> +
>>       err = rhltable_insert_key(&sctp_transport_hashtable, &arg,
>>                                 &t->node, sctp_hash_params);
>> +
>> +out:
>
> Well, what if another thread of control inserts a matching transport
> after you've checked the list but before rhltable_insert_key() does
> it's work?
>
> What write side lock is being held to protect the table from
> modifications here?
sock lock.
...
sctp_assoc_add_peer()
  sctp_hash_transport()
     rhltable_insert_key()

all the places where it call  sctp_assoc_add_peer() are proctected by
lock_sock(). it's a big lock, no need to worry about race issues here.
