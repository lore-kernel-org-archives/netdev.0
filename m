From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 0/4] net-next: dsa: fix flow dissection
Date: Thu, 10 Aug 2017 09:40:13 +0200
Message-ID: <278db83e-6092-e9e7-e94d-d8e07acaa449@phrozen.org>
References: <20170809124119.24320-1-john@phrozen.org>
 <20170809.225243.2204411285392662424.davem@davemloft.net>
 <1502347335.4936.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, muciri@openmesh.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        sean.wang@mediatek.com, linux-kernel@vger.kernel.org,
        shashidhar.lakkavalli@openmesh.com,
        linux-mediatek@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502347335.4936.2.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 10/08/17 08:42, Eric Dumazet wrote:
> On Wed, 2017-08-09 at 22:52 -0700, David Miller wrote:
>> From: John Crispin <john@phrozen.org>
>> Date: Wed,  9 Aug 2017 14:41:15 +0200
>>
>>> RPS and probably other kernel features are currently broken on some if not
>>> all DSA devices. The root cause of this is that skb_hash will call the
>>> flow_dissector. At this point the skb still contains the magic switch
>>> header and the skb->protocol field is not set up to the correct 802.3
>>> value yet. By the time the tag specific code is called, removing the header
>>> and properly setting the protocol an invalid hash is already set. In the
>>> case of the mt7530 this will result in all flows always having the same
>>> hash.
>>>
>>> Changes since RFC:
>>> * use a callback instead of static values
>>> * add cover letter
>> Series applied, thanks.
> Is this related ?
>
> net/core/flow_dissector.c: In function '__skb_flow_dissect':
> net/core/flow_dissector.c:448:18: error: 'struct net_device' has no member named 'dsa_ptr'
>      ops = skb->dev->dsa_ptr->tag_ops;
>                    ^
> make[3]: *** [net/core/flow_dissector.o] Error 1
>
>

looks like it, I did test the patches against net-next from 24 hours 
ago, let me do a test build just now.
     John


> _______________________________________________
> Linux-mediatek mailing list
> Linux-mediatek@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-mediatek
