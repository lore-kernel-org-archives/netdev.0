From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: Tue, 14 Jan 2003 14:15:27 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0301141409320.2142-100000@dyn9-47-18-86.beaverton.ibm.com>
References: <1042575066.2610.26.camel@devil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>, <kuznet@ms2.inr.ac.ru>,
   <jgrimm2@us.ibm.com>, <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mika Liljeberg <mika.liljeberg@welho.com>
In-Reply-To: <1042575066.2610.26.camel@devil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 14 Jan 2003, Mika Liljeberg wrote:

> On Tue, 2003-01-14 at 20:44, Sridhar Samudrala wrote:
> > Frankly, i haven't thought of IPV6 in detail. I was under the impression that
> > it is simpler in ipv6 as only source is allowed to do fragmentation and as there
> > is no DF bit, it will automatically fragment any packets larger than the pmtu.
> > But looking at ip6_xmit(), i realize that ICMPV6_PKT_TOOBIG error is generated
> > forcing the transport layer to do the fragmentation. TCP can handle this, but
> > SCTP cannot.
> 
> IPv6 is simpler, because the specification asserts that every IPv6
> capable link must support a MTU of at least 1280 bytes. If you don't
> generate packets larger than this you don't have to worry about
> fragmentation.
> 
> If you want larger data chunks, then you have to solve this for IPv6 as
> well.

Yes. If we restrict the max. data chunksize to 1280 bytes for ipv6 and 576 bytes
for ipv4, we could have avoided ip fragmentation alltogether. 
But this will add unnecessary overhead of sctp fragmentation/reassembly and
additional chunk headers when the real pmtu is much larger and the messages are
big.

Thanks
Sridhar
