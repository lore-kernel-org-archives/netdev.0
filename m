From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 net-next 0/4] kernel TLS
Date: Wed, 14 Jun 2017 22:15:53 +0200
Message-ID: <1497471353.765278.1009639400.15AB6F46@webmail.messagingengine.com>
References: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
 <20170614.154759.673143940024124611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ilyal@mellanox.com, aviadye@mellanox.com, borisp@mellanox.com,
        liranl@mellanox.com, matanb@mellanox.com, netdev@vger.kernel.org,
        tom@herbertland.com, herbert@gondor.apana.org.au,
        linux-crypto@vger.kernel.org, eric.dumazet@gmail.com,
        alexei.starovoitov@gmail.com, nmav@gnutls.org,
        fridolin.pokorny@gmail.com
To: David Miller <davem@davemloft.net>, davejwatson@fb.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20170614.154759.673143940024124611.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

On Wed, Jun 14, 2017, at 21:47, David Miller wrote:
> From: Dave Watson <davejwatson@fb.com>
> Date: Wed, 14 Jun 2017 11:36:54 -0700
> 
> > This series adds support for kernel TLS encryption over TCP sockets.
> > A standard TCP socket is converted to a TLS socket using a setsockopt.
> > Only symmetric crypto is done in the kernel, as well as TLS record
> > framing.  The handshake remains in userspace, and the negotiated
> > cipher keys/iv are provided to the TCP socket.
> > 
> > We implemented support for this API in OpenSSL 1.1.0, the code is
> > available at https://github.com/Mellanox/tls-openssl/tree/master
> > 
> > It should work with any TLS library with similar modifications,
> > a test tool using gnutls is here: https://github.com/Mellanox/tls-af_ktls_tool
> > 
> > RFC patch to openssl:
> > https://mta.openssl.org/pipermail/openssl-dev/2017-June/009384.html
>  ...
> 
> I really want to apply this, so everyone give it a good review :-)

one question for this patch set:

What is the reason for not allowing key updates for the TX path? I was
always loud pointing out the problems with TLSv1.2 renegotiation and
TLSv1.3 key update alerts. This patch set uses encryption in a
synchronous way directly in the socket layer and thus wouldn't suffer
from problems regarding updates of the key. My hunch is that you leave
this option open so you can later on introduce asynchronous crypto which
might be used on hardware? It looks also be doable in case of MSG_MORE.
Otherwise by allowing key updates to the data path I would not see any
problems with key updates in TLS.

The reason why I am asking is that it is hard to predict how many bytes
will be send through a connection. TLSv1.3 recommends (SHOULD)
implementation writes to update the key after 362GB, afaik NIST even has
a lower margin. After that the symmetric crypto might become too weak.

Anyway, this patch seems easy and maybe with key updates added later on
doesn't seem to have any problems pointed out by me so far.

Thanks,
Hannes
