From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: v3.12-stable-queue build errors
Date: Mon, 27 Apr 2015 10:35:51 -0500
Message-ID: <87fv7lk2i0.fsf@x220.int.ebiederm.org>
References: <20150425141609.GA1147@roeck-us.net> <553DF71E.7060409@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>, stable@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <553DF71E.7060409@suse.cz> (Jiri Slaby's message of "Mon, 27 Apr
	2015 10:45:18 +0200")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Slaby <jslaby@suse.cz> writes:

> On 04/25/2015, 04:16 PM, Guenter Roeck wrote:
>> Several powerpc build fail with:
>> 
>> drivers/net/ethernet/freescale/gianfar.c: In function 'gfar_start_xmit':
>> drivers/net/ethernet/freescale/gianfar.c:2146:3: error: implicit declaration of
>> function 'dev_consume_skb_any' [-Werror=implicit-function-declaration]
>>    dev_consume_skb_any(skb);
>> 
>> dev_consume_skb_any() does not exist in 3.12.
>> 
>> Introduced by 'gianfar: Carefully free skbs in functions called by netpoll'.
>
> Eric, David,
>
> what action should I take here?
>
> 1) take also:
> commit e6247027e5173c00efb2084d688d06ff835bc3b0
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Thu Dec 5 04:45:08 2013 -0800
>
>     net: introduce dev_consume_skb_any()
>
>
> 2) drop 'gianfar: Carefully free skbs in functions called by netpoll'
> from stable-3.12

This is probably the most reasonable.   KISS.

> 3) any other idea?

#define dev_consume_sky_any dev_kfree_skb_any

The correctness fix is updating the code to handle any context.  The
consume vs kfree accouting difference is not particularly interesting.

Eric
