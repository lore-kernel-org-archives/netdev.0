From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 08:12:58 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610080901.M37190@shell.cyberus.ca>
References: <Pine.LNX.4.44.0306101432530.21247-100000@netcore.fi>
 <3EE5C7E9.6090401@monmouth.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pekka Savola <pekkas@netcore.fi>, ralph+d@istop.com,
   CIT/Paul <xerox@foonet.net>, "'Simon Kirby'" <sim@netnation.com>,
   "'David S. Miller'" <davem@redhat.com>,
   "fw@deneb.enyo.de" <fw@deneb.enyo.de>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "John S. Denker" <jsd@monmouth.com>
In-Reply-To: <3EE5C7E9.6090401@monmouth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 10 Jun 2003, John S. Denker wrote:

> On 06/10/2003 07:41 AM, Pekka Savola wrote:
> >
> >>Typical packet is around 500 bytes
> >>average.
> >
> > Not sure that's really the case.  I have the impression the traffic is
> > basically something like:
> >  - close to 1500 bytes (data transfers)
> >  - between 40-100 bytes (TCP acks, simple UDP requests, etc.)
> >  - something in between
>
> It helps to take a more sophisticated view of things.
> In typical networks:
> Most of the packet-count is to be found in small packets.
> Most of the byte-count is to be found in large packets.
>
> Some things (e.g. routing) depend mainly on the packet-count.
> Other things (e.g. encryption, layer-1 hardware requirements,
> memory bandwidth usage, ISP contracts) are sensitive to the
> byte-count.
>
> We shouldn't optimize one at the expense of the other.

You bring a good point.
Theres another dimension actually: mostly driven by BSD mbuff style
packet allocation; some tests show that some vendors are optimized
for certain packet sizes, Linux skbuffs dont have this problem.
We dont optimize for packet sizes given the linear nature of skbuffs.
Donalds ether drivers tend to amortize some of the costs by reallocating
skbs when the packet <= 100 bytes, but this is no longer valid with
skb recycling and the magazine layer appearing in the slab.

cheers,
jamal
