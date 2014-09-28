From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] mlx4: optimize xmit path
Date: Sun, 28 Sep 2014 13:49:21 -0700
Message-ID: <CAMEtUuw861ZM+jvtFnJtwTS9krUFy09Z+rj-9LJ3UYRzOEd9zA@mail.gmail.com>
References: <CAMEtUuxwQ8k1wcT8U0VncnVoN=vZjU3zxswgjYPcQTLPw2pRwA@mail.gmail.com>
	<1411930364.15768.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34935 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427AbaI1UtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 16:49:23 -0400
Received: by mail-lb0-f174.google.com with SMTP id l4so16658088lbv.5
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 13:49:21 -0700 (PDT)
In-Reply-To: <1411930364.15768.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014 at 11:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2014-09-28 at 11:07 -0700, Alexei Starovoitov wrote:
>
>> this is great improvement!
>> Thank you for leading this effort.
>> 10G line rate is definitely nice :)
>> Hopefully Or can demo similar numbers with 40G nic as well :)
>>
>> > +       if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
>> > +           !vlan_tx_tag_present(skb) && send_doorbell) {
>>
>> feels something wrong here, since it checks for
>> send_doorbell, but iowrite() happens in the 'else' part
>> of this branch with another 'if (send_doorbell)'
>>
>
> If we do not plan to send a doorbell, we should not use blueframe.
>
> Blueframe is always sending a doorbell by design, as it uses a single
> flip buffer.
>
> So if you want to see any improvement thanks to skb->xmit_more, we have
> to use the iowrite32(), not the blueframe.
>
> Therefore , if send_doorbell == false, we do not want the doorbell

I see. So xmit_more=true overrides blueflame=on settings.
I wonder what is the performance difference bf=on vs bf=off,
also whether a burst of N packets via bf is slower than
burst via queue+doorbell.
Some fun exploration for driver experts :)

> Is it making sense now ? ;)

It did, but only after studying this BlueFlame thingy ;)

Thanks!
