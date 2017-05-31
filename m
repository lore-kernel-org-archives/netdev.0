From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 6/6] net: dsa: factor skb freeing on xmit
Date: Wed, 31 May 2017 14:18:30 -0400
Message-ID: <87y3tchouh.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170530183319.10718-1-vivien.didelot@savoirfairelinux.com> <20170530183319.10718-7-vivien.didelot@savoirfairelinux.com> <8487d628-874e-cc45-a15a-07725930dbc2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8487d628-874e-cc45-a15a-07725930dbc2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 05/30/2017 11:33 AM, Vivien Didelot wrote:
>> The taggers are currently responsible to free the original SKB if they
>> made a copy of it, or in case of error.
>> 
>> This patch simplifies this by freeing the original SKB in the
>> dsa_slave_xmit caller, but only if an error (NULL) is returned.
>
> Is not it a clearer contract if the tagging protocol must always free
> the original SKB, whether it succeeded in creating a new one or not?

The rcv caller frees the original SKB on error, as of a86d8becc3f0
("net: dsa: Factor bottom tag receive functions").

It'd be nice if we could make both xmit and rcv symmetric, and limit the
tagging implementations to only do their real job: tag/untag an SKB with
the destination/source port.

Thanks,

        Vivien
