From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: [PATCH] can: check for null sk before deferencing it via the call
 to sock_net
Date: Mon, 16 Oct 2017 12:37:07 -0400
Message-ID: <CA+5PVA7fJfZmN-XLuqARGkWL6eY54HaRAj19K_Und3K7vAVfpg@mail.gmail.com>
References: <20170908150235.2931-1-colin.king@canonical.com> <f5ce1047-eb37-151a-c7b7-9b47b70789f7@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Colin King <colin.king@canonical.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S . Miller" <davem@davemloft.net>,
        linux-can@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f5ce1047-eb37-151a-c7b7-9b47b70789f7@hartkopp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 8, 2017 at 1:46 PM, Oliver Hartkopp <socketcan@hartkopp.net> wrote:
>
>
> On 09/08/2017 05:02 PM, Colin King wrote:
>>
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> The assignment of net via call sock_net will dereference sk. This
>> is performed before a sanity null check on sk, so there could be
>> a potential null dereference on the sock_net call if sk is null.
>> Fix this by assigning net after the sk null check. Also replace
>> the sk == NULL with the more usual !sk idiom.
>>
>> Detected by CoverityScan CID#1431862 ("Dereference before null check")
>>
>> Fixes: 384317ef4187 ("can: network namespace support for CAN_BCM
>> protocol")
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>
>
> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

I don't see this one queued up in the net or net-next trees.  Did it
fall through the cracks or did it get queued up elsewhere?  Seems like
it's a good candidate to get into 4.14?

josh

>
>
> Thanks Collin!
>
>
>> ---
>>   net/can/bcm.c | 5 +++--
>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/can/bcm.c b/net/can/bcm.c
>> index 47a8748d953a..a3791674b8ce 100644
>> --- a/net/can/bcm.c
>> +++ b/net/can/bcm.c
>> @@ -1493,13 +1493,14 @@ static int bcm_init(struct sock *sk)
>>   static int bcm_release(struct socket *sock)
>>   {
>>         struct sock *sk = sock->sk;
>> -       struct net *net = sock_net(sk);
>> +       struct net *net;
>>         struct bcm_sock *bo;
>>         struct bcm_op *op, *next;
>>   -     if (sk == NULL)
>> +       if (!sk)
>>                 return 0;
>>   +     net = sock_net(sk);
>>         bo = bcm_sk(sk);
>>         /* remove bcm_ops, timer, rx_unregister(), etc. */
>>
>
