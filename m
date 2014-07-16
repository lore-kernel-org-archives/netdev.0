From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Wed, 16 Jul 2014 15:15:53 +0300
Message-ID: <CAJZOPZKH=vkWs4oF8pKXiX-tx6rDaqyt_4oudZgxzMWp-QW5VA@mail.gmail.com>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
	<CAJZOPZ+wu=6t_AKoKg1KhVJ0=DhczfQ8ekDFKFLEkQv6d=cOfA@mail.gmail.com>
	<CAPshTCjiw8vFK9Y4APwsX5kWnKDByLuOn+1MJa4C08FOevZKQQ@mail.gmail.com>
	<CAJZOPZLwiT7LhxDFYdAq=0iU6heSwBQfCvwxXtoAXMqg=eNAmA@mail.gmail.com>
	<CAPshTCiKnKx_P=JLQcgjS36rWmCtSS43XYNJHeif9Z9yP8C36Q@mail.gmail.com>
	<CAJZOPZJcxb1j+_A2T=yN8bkjBH3CFjnb05q56dxAwtZ4i85Mpw@mail.gmail.com>
	<CAPshTCgCdJNH6rr-Yri0L8-aDL_kQfWbY9XtwVLxsoHcf-9Ghg@mail.gmail.com>
	<CAJZOPZLqqBad5p_TH2gvHsWOgrNWdwUz0A4x-20mr2Jw-Ev=8Q@mail.gmail.com>
	<CAPshTCh66uHYgftjUO8YjeTZum9mbkd4xO-D15k1Ww7_fV8pAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:46848 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758457AbaGPMPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 08:15:54 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so635965qge.2
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 05:15:53 -0700 (PDT)
In-Reply-To: <CAPshTCh66uHYgftjUO8YjeTZum9mbkd4xO-D15k1Ww7_fV8pAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 11:22 PM, Jerry Chu <hkchu@google.com> wrote:
> On Tue, Jul 15, 2014 at 11:21 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:

>> I am not near the code now, but AFAIK, the "stack" sets it in the TX path
>> and the driver sets it in the RX path, any deviation you see there for this
>> convension except for the change introduced by this patch.

> Where does the forwarding path (e.g., the case at hand) belong then?

yep, so forwarding flow is something like

HW --> driver RX --> stack RX --> some stack processing --> stack TX
--> driver TX --> HW

and this is different from a path of

application --> stack TX --> driver TX --> HW

It seems as of even before we throw in the tunneling thing, the GRO stack
which is part of that "stack RX" code I mentioned above sets the
gso_type of SKBs
for the sake of forwarding  so these things already happen.

> AFAICT the current dev_hard_start_xmit() code pretty much requires
> skb->encapsulation to be set on all tunneled pkts in order for the proper
> TX offload to be possible.
