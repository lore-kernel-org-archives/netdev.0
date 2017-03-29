From: David Miller <davem@davemloft.net>
Subject: Re: [RFC TLS Offload Support 00/15] cover letter
Date: Wed, 29 Mar 2017 10:41:22 -0700 (PDT)
Message-ID: <20170329.104122.139835608303809432.davem@davemloft.net>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilyal@mellanox.com, borisp@mellanox.com, davejwatson@fb.com,
        netdev@vger.kernel.org, matanb@mellanox.com, liranl@mellanox.com,
        haggaie@mellanox.com, tom@herbertland.com,
        herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: aviadye@mellanox.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aviad Yehezkel <aviadye@mellanox.com>
Date: Tue, 28 Mar 2017 16:26:17 +0300

> TLS Tx crypto offload is a new feature of network devices. It
> enables the kernel TLS socket to skip encryption and authentication
> operations on the transmit side of the data path, delegating those
> to the NIC. In turn, the NIC encrypts packets that belong to an
> offloaded TLS socket on the fly. The NIC does not modify any packet
> headers. It expects to receive fully framed TCP packets with TLS
> records as payload. The NIC replaces plaintext with ciphertext and
> fills the authentication tag. The NIC does not hold any state beyond
> the context needed to encrypt the next expected packet,
> i.e. expected TCP sequence number and crypto state.

It seems like, since you do the TLS framing in TCP and the card is
expecting to fill in certain aspects, there is a requirement that the
packet contents aren't mangled between the TLS framing code and when
the SKB hits the card.

Is this right?

For example, what happens if netfilter splits a TLS Tx offloaded frame
into two TCP segments?
