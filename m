From: Dave Watson <davejwatson@fb.com>
Subject: Re: [PATCH v3 net-next 0/4] kernel TLS
Date: Wed, 14 Jun 2017 15:06:26 -0700
Message-ID: <20170614220626.GB72301@davejwatson-mba.dhcp.thefacebook.com>
References: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
 <20170614.154759.673143940024124611.davem@davemloft.net>
 <1497471353.765278.1009639400.15AB6F46@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <ilyal@mellanox.com>,
        <aviadye@mellanox.com>, <borisp@mellanox.com>,
        <liranl@mellanox.com>, <matanb@mellanox.com>,
        <netdev@vger.kernel.org>, <tom@herbertland.com>,
        <herbert@gondor.apana.org.au>, <linux-crypto@vger.kernel.org>,
        <eric.dumazet@gmail.com>, <alexei.starovoitov@gmail.com>,
        <nmav@gnutls.org>, <fridolin.pokorny@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1497471353.765278.1009639400.15AB6F46@webmail.messagingengine.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hannes, 

On 06/14/17 10:15 PM, Hannes Frederic Sowa wrote:
> one question for this patch set:
> 
> What is the reason for not allowing key updates for the TX path? I was
> always loud pointing out the problems with TLSv1.2 renegotiation and
> TLSv1.3 key update alerts. This patch set uses encryption in a
> synchronous way directly in the socket layer and thus wouldn't suffer
> from problems regarding updates of the key. My hunch is that you leave
> this option open so you can later on introduce asynchronous crypto which
> might be used on hardware? It looks also be doable in case of MSG_MORE.
> Otherwise by allowing key updates to the data path I would not see any
> problems with key updates in TLS.

I don't currently have any reasons to not support renegotation, we
just don't currently use it, so I didn't add support for it.  I don't
work on the hardware, but yes it looks like it would have to keep the
old keys around until everything sent using them has been acked.

> Anyway, this patch seems easy and maybe with key updates added later on
> doesn't seem to have any problems pointed out by me so far.

Indeed, it would be easy to flush any unencrypted data, and then
change the keys.
