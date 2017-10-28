From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] can: Use common error handling code in vxcan_newlink()
Date: Sat, 28 Oct 2017 10:23:02 +0200
Message-ID: <d3bdd3c0-5a03-dd59-07ca-94b126c67f75@users.sourceforge.net>
References: <2e600d9a-faec-dd39-08f0-5a7fb260d7ca@users.sourceforge.net>
 <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Wolfgang Grandegger <wg@grandegger.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2ab5d794-7a5c-9036-835c-67cfcc541795@hartkopp.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> @@ -227,10 +227,8 @@ static int vxcan_newlink(struct net *net, struct net_device *dev,
>>       netif_carrier_off(peer);
>>         err = rtnl_configure_link(peer, ifmp);
>> -    if (err < 0) {
>> -        unregister_netdevice(peer);
>> -        return err;
>> -    }
>> +    if (err)
>> +        goto unregister_network_device;
> 
> You are changing semantic in the if-statement here.

I got an other software development opinion for this implementation detail.

http://elixir.free-electrons.com/linux/v4.14-rc6/source/net/core/rtnetlink.c#L2393
https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/net/core/rtnetlink.c?id=36ef71cae353f88fd6e095e2aaa3e5953af1685d#n2513

The success predicate for the function “rtnl_configure_link” is that
the return value is zero. I would prefer to treat other values as
an error code then.


> I would be fine with the patch

Thanks for a bit of change acceptance.


> if you revert that if-statement as I would like to stay on the behavior
> from veth.c in veth_newlink().

Will another bit of clarification be useful around the usage of error predicates?

Regards,
Markus
