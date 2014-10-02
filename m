From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH V6 0/2] qdisc: bulk dequeue support
Date: Thu, 2 Oct 2014 08:27:36 -0700
Message-ID: <CA+mtBx-dYMRCTz651Nd4emO9gutynLvXzLRuqVkMbF+HhyGRPg@mail.gmail.com>
References: <20141001203345.3321.99675.stgit@dragon>
	<CA+mtBx8ecpd+S+E2o8A+Hzp3i2SO7XO0+F_DYA0ng+fjta7G5A@mail.gmail.com>
	<1412262270.16704.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37071 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbaJBP1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 11:27:37 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so1179259igc.12
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 08:27:36 -0700 (PDT)
In-Reply-To: <1412262270.16704.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 2, 2014 at 8:04 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-10-02 at 07:42 -0700, Tom Herbert wrote:
>
>
>> Unfortunately we probably still need something. If BQL were disabled
>> (by setting BQL min_limit to infinity) then we'll always dequeue all
>> the packets in the qdisc. Disabling BQL might be legitimate in
>> deployment if say a bug is found in a device that prevents prompt
>> transmit completions for some corner case.
>
>
> Unfortunately, there is nothing we can do if a ndo_start_xmit() function
> is buggy.
>
I was referring more to device bugs not driver bugs. But even so, if a
user hits a problem like this in the system, disabling something like
BQL would probably be a better recourse than bringing their network
down.

Minimally we should at least test with BQL disabled, it might not be
so horrible. I suppose in the worse case we're at least limited by the
qdisc limit.

> For example, if a prior packet is queued on NIC TX ring (with xmit_more
> set to 1)
>
> Then following packet given to ndo_start_xmit() returns infamous
> NETDEV_TX_BUSY, we are screwed.
>
> mlx4 driver for example has this bug.
>
>
> Thats why I advocate we have no artifical limit : We are going to catch
> driver bugs sooner and fix them before xmit_more support is validated,
> for each driver that claims to support it.
>
> Amir, the problem with NETDEV_TX_BUSY in mlx4 need to be fixed.
>
>
