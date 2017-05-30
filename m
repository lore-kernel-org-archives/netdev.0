From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 6/7] net: dsa: remove useless copy of tagger xmit
Date: Tue, 30 May 2017 11:43:54 -0400
Message-ID: <87zidu2vut.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com> <20170530142131.23568-7-vivien.didelot@savoirfairelinux.com> <20170530152943.GH22758@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530152943.GH22758@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>>  	/* Transmit function may have to reallocate the original SKB */
>> -	nskb = p->xmit(skb, dev);
>> +	nskb = p->dp->ds->dst->tag_ops->xmit(skb, dev);
>
> This is also the hot path for DSA transmit. Do we really want to do 4
> extra pointer dereferences a million times per second, compared to one
> copy during setup?

Yep I get the idea. It felt weird to copy structure members like this
and not at least reusing the dsa_device_ops structure.

Thanks,

        Vivien
