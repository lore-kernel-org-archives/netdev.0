From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/8] gtp: switch from struct socket to
 struct sock for the GTP sockets
Date: Wed, 15 Feb 2017 11:07:26 -0500 (EST)
Message-ID: <20170215.110726.1948359807046911436.davem@davemloft.net>
References: <20170213153624.14170-3-aschultz@tpip.net>
        <20170214.124815.217549517821684819.davem@davemloft.net>
        <1372457526.113429.1487142296624.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org, laforge@gnumonks.org,
        Lionel.Gauthier@eurecom.fr, osmocom-net-gprs@lists.osmocom.org,
        jonas@southpole.se
To: aschultz@tpip.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbdBOQHd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 11:07:33 -0500
In-Reply-To: <1372457526.113429.1487142296624.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schultz <aschultz@tpip.net>
Date: Wed, 15 Feb 2017 08:04:56 +0100 (CET)

> ----- On Feb 14, 2017, at 6:48 PM, David S. Miller davem@davemloft.net wrote:
> 
>> From: Andreas Schultz <aschultz@tpip.net>
>> Date: Mon, 13 Feb 2017 16:36:18 +0100
>> 
>>> +	if (gtp->sk0) {
>>> +		udp_sk(gtp->sk0)->encap_type = 0;
>>> +		rcu_assign_sk_user_data(gtp->sk0, NULL);
>>> +		sock_put(gtp->sk0);
>>>  	}
>> 
>> This does "sock_put(NULL);" because you are assigning gtp->sk0 to
>> NULL before the sock_put() call.  So you are leaking the socket,
>> at best.
> 
> I don't understand how this should happen. If I where to use rcu_assign_pointer,
> then yes, but rcu_assign_sk_user_data does assign to the sk_user_data member
> of struct sock and not to the argument itself.

You are right, I misread the assignment.
