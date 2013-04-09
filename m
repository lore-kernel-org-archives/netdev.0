From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Tue, 9 Apr 2013 15:05:42 +0100
Message-ID: <1365516342.2623.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <3505145.vfXt1x4t0P@sifl>
	 <1365469759.3887.69.camel@edumazet-glaptop>
	 <51636DEB.5000308@schaufler-ca.com> <28452040.xEi3pLPik0@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<mvadkert@redhat.com>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <28452040.xEi3pLPik0@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-09 at 09:19 -0400, Paul Moore wrote:
> On Monday, April 08, 2013 06:24:59 PM Casey Schaufler wrote:
> > On 4/8/2013 6:09 PM, Eric Dumazet wrote:
> > > On Mon, 2013-04-08 at 17:59 -0700, Casey Schaufler wrote:
> > >> I don't see that with adding 4 bytes. Again, I'm willing to be
> > >> educated if I'm wrong.
> > > 
> > > Feel free to add 4 bytes without having the 'align to 8 bytes' problem
> > > on 64 bit arches. Show us your patch.
> > 
> > Recall that it's replacing an existing 4 byte value with an 8 byte value.
> > My compiler days were quite short and long ago, but it would seem that
> > an 8 byte value ought not have an 'align to 8 bytes' problem.
> > 
> > Again, I'm willing to be educated.
> 
> Armed with a cup of coffee I took a look at the sk_buff structure this morning 
> with the pahole tool and using the current sk_buff if we turn on all the 
> #ifdefs here is what I see on x86_64:
> 
> struct sk_buff {
[...]
>         sk_buff_data_t             inner_transport_header; /*   200     8 */
>         sk_buff_data_t             inner_network_header; /*   208     8 */
>         sk_buff_data_t             transport_header;     /*   216     8 */
>         sk_buff_data_t             network_header;       /*   224     8 */
>         sk_buff_data_t             mac_header;           /*   232     8 */
>         sk_buff_data_t             tail;                 /*   240     8 */
>         sk_buff_data_t             end;                  /*   248     8 */
[...]

This is wrong; sk_buff_data_t is always 32-bit:

#if BITS_PER_LONG > 32
#define NET_SKBUFF_DATA_USES_OFFSET 1
#endif

#ifdef NET_SKBUFF_DATA_USES_OFFSET
typedef unsigned int sk_buff_data_t;
#else
typedef unsigned char *sk_buff_data_t;
#endif

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

