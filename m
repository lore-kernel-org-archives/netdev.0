From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: net/can: warning in raw_setsockopt/__alloc_pages_slowpath
Date: Fri, 2 Dec 2016 18:05:48 +0100
Message-ID: <6fe05efd-eb2c-a5e2-9d45-48f2c3098abb@hartkopp.net>
References: <CAAeHK+x3vqjzzXPtp-xCshWnvTcVrZqGmJR7rbooRFxBJanv8g@mail.gmail.com>
 <c47865a1-4aae-5eae-f9e0-7b4f7f7e9897@pengutronix.de>
 <73b78023-bc11-25c0-33e3-3a748dbc81cd@hartkopp.net>
 <74e2aed8-ba38-ee91-59a3-49131ea18d60@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <74e2aed8-ba38-ee91-59a3-49131ea18d60@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/02/2016 04:42 PM, Marc Kleine-Budde wrote:
> On 12/02/2016 04:11 PM, Oliver Hartkopp wrote:
>>
>>
>> On 12/02/2016 02:24 PM, Marc Kleine-Budde wrote:
>>> On 12/02/2016 01:43 PM, Andrey Konovalov wrote:
>>
>>
>>>>  [<ffffffff8369e0de>] raw_setsockopt+0x1be/0x9f0 net/can/raw.c:506
>>>
>>> We should add a check for a sensible optlen....
>>>
>>>> static int raw_setsockopt(struct socket *sock, int level, int optname,
>>>> 			  char __user *optval, unsigned int optlen)
>>>> {
>>>> 	struct sock *sk = sock->sk;
>>>> 	struct raw_sock *ro = raw_sk(sk);
>>>> 	struct can_filter *filter = NULL;  /* dyn. alloc'ed filters */
>>>> 	struct can_filter sfilter;         /* single filter */
>>>> 	struct net_device *dev = NULL;
>>>> 	can_err_mask_t err_mask = 0;
>>>> 	int count = 0;
>>>> 	int err = 0;
>>>>
>>>> 	if (level != SOL_CAN_RAW)
>>>> 		return -EINVAL;
>>>>
>>>> 	switch (optname) {
>>>>
>>>> 	case CAN_RAW_FILTER:
>>>> 		if (optlen % sizeof(struct can_filter) != 0)
>>>> 			return -EINVAL;
>>>
>>> here...
>>>
>>> 		if (optlen > 64 * sizeof(struct can_filter))
>>> 			return -EINVAL;
>>>
>>
>> Agreed.
>>
>> But what is sensible here?
>> 64 filters is way to small IMO.
>>
>> When thinking about picking a bunch of single CAN IDs I would tend to
>> something like 512 filters.
>
> Ok - 64 was just an arbitrary chosen value for demonstration purposes :)
>

:-)

Would you like to send a patch?

Regards,
Oliver
