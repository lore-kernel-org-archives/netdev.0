From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Fri, 19 Nov 2004 18:00:21 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0411191755160.2567@w-sridhar.beaverton.ibm.com>
References: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
 <E1CUAQ2-0002jT-00@gondolin.me.apana.org.au> <20041116163106.3b62a39a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041116163106.3b62a39a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 16 Nov 2004, David S. Miller wrote:

> On Wed, 17 Nov 2004 07:59:18 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> > Sridhar Samudrala <sri@us.ibm.com> wrote:
> > > We are seeing following assertions when running specweb99 with
> > > tcp_tso_win_divisor lowered to 4, 2 or 1 on linux 2.6.9 based kernels.
> >
> > 2.6.9 is known to have bugs in TCP book-keeping.  Please try 2.6.10-rc2
> > instead.
>
> Actually, that's true.  I missed that this report was against
> 2.6.9 vanilla, TCP is buggy as can be wrt TSO in that
> release.

Unfortunately as we cannot upgrade to 2.6.10-rc2, i tried to locate all the
TSO accounting related bugfixes that went in after 2.6.9 and came up with
the following 4 patches.

[TCP]: Fix new packet len calc in tcp_fragment()
http://linux.bkbits.net:8080/linux-2.5/cset@4175f423T1X-UctOUzkYgMxq16ODAw?nav=index.html|src/|src/net|src/net/ipv4|related/net/ipv4/tcp_output.c

[TCP]: Fix tcp_trim_head() calculations.
http://linux.bkbits.net:8080/linux-2.5/cset@41789ca8a4gfwR352SuIgAl6GbQmbQ?nav=index.html|src/|src/net|src/net/ipv4|related/net/ipv4/tcp_output.c

[TCP]: Only re-set TSO size for packet which was TSO to begin with.
http://linux.bkbits.net:8080/linux-2.5/cset@417982139wJw8yO-JClu818UQuoa_g?nav=index.html|src/|src/net|src/net/ipv4|related/net/ipv4/tcp_output.c

[TCP]: Handle real partial-ACKs of TSO frames correctly.
http://linux.bkbits.net:8080/linux-2.5/cset@417dcb39pNYZ1fRBQTQES0JVcUji2g?nav=index.html|src/|src/net|src/net/ipv4|related/net/ipv4/tcp_output.c

Even with these 4 patches applied, we are still seeing the assertions.

Also, the webserver is started only after lowering tcp_tso_win_divisor and
the value is is not changed again.

Are there any other TSO related patches apart from the above 4 that went in
after 2.6.9? Or could it be that this bug is still there?

Thanks
Sridhar
