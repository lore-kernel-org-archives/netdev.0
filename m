From: Dave Watson <davejwatson@fb.com>
Subject: Re: [PATCH v3 net-next 1/4] tcp: ULP infrastructure
Date: Mon, 31 Jul 2017 15:16:14 -0700
Message-ID: <20170731221614.GB93172@dhcp-172-20-173-153.dhcp.thefacebook.com>
References: <cover.1497465295.git.davejwatson@fb.com>
 <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
 <CALx6S35SmGC1ZSC9EiDH0gCUxGcFOJOTPOR-NzrgafKNC8oMYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Nikos Mavrogiannopoulos <nmav@gnutls.org>,
        =?iso-8859-1?Q?Fridol=EDn_Pokorn=FD?= <fridolin.pokorny@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALx6S35SmGC1ZSC9EiDH0gCUxGcFOJOTPOR-NzrgafKNC8oMYg@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/29/17 01:12 PM, Tom Herbert wrote:
> On Wed, Jun 14, 2017 at 11:37 AM, Dave Watson <davejwatson@fb.com> wrote:
> > Add the infrustructure for attaching Upper Layer Protocols (ULPs) over TCP
> > sockets. Based on a similar infrastructure in tcp_cong.  The idea is that any
> > ULP can add its own logic by changing the TCP proto_ops structure to its own
> > methods.
> >
> > Example usage:
> >
> > setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));
> >
> One question: is there a good reason why the ULP infrastructure should
> just be for TCP sockets. For example, I'd really like to be able
> something like:
> 
> setsockopt(sock, SOL_SOCKET, SO_ULP, &ulp_param, sizeof(ulp_param));
> 
> Where ulp_param is a structure containing the ULP name as well as some
> ULP specific parameters that are passed to init_ulp. ulp_init could
> determine whether the socket family is appropriate for the ULP being
> requested.

Using SOL_SOCKET instead seems reasonable to me.  I can see how
ulp_params could have some use, perhaps at a slight loss in clarity.
TLS needs its own setsockopts anyway though, for renegotiate for
example.
