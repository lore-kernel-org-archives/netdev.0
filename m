From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: x25: possible skb leak on bad facilities
Date: Mon, 7 Feb 2011 17:29:43 +1100
Message-ID: <AANLkTik8hg5G2FYDCoRgh72v-_euGWKix9Fxm89UdXie@mail.gmail.com>
References: <20110131130826.GC16804@shadowen.org>
	<AANLkTik-ywwtNg2AxAXtsKYJviDp=1zCZ-43JXp9i3g6@mail.gmail.com>
	<20110206.202824.260090071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: apw@canonical.com, john@calva.com, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tim.gardner@canonical.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110206.202824.260090071.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The issue is a bit more complex than Andy's patch, I think I have a full fix.
Burning it in on test system now, if thats OK ill post patch in a few hours.


On Mon, Feb 7, 2011 at 3:28 PM, David Miller <davem@davemloft.net> wrote:
> From: Andrew Hendry <andrew.hendry@gmail.com>
> Date: Tue, 1 Feb 2011 22:55:13 +1100
>
>> There are two callers, when I was crashing it I don't remember it
>> using the backlog path.
>> x25_process_rx_frame is called from both x25_backlog_rcv and also
>> x25_receive_data (via x25_lapb_receive_frame)
>>
>> But reviewing that second path now it looks like it will also leak, -1
>> would make it skip the kfree_skb there as well.
>> So patch looks good to me, when I have some time I'll run it through
>> the environment I had setup originally to confirm.
>
> Andrew, have you had a chance to do this yet?
>
