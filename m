From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 25/29] xen: Add the Xen virtual network device driver.
Date: Sat, 05 May 2007 03:05:07 -0700
Message-ID: <463C56D3.8060609@goop.org>
References: <20070504232051.411946839@goop.org>
	<20070504232121.492190579@goop.org>
	<20070505091624.GA8890@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>,
        Jeremy Fitzhardinge <jeremy@goop.org>, Andi Kleen <ak@suse.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        virtualization@lists.osdl.org, lkml <linux-kernel@vger.kernel.org>,
        Chris Wright <chrisw@sous-sol.org>,
        Ian Pratt <ian.pratt@xensource.com>,
        Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
        netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
        Stephen Hemminger <shemminge@linux-foundation.org>,
        Rusty Russell <rusty@rustcorp.com.au>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20070505091624.GA8890@infradead.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> There only seems to be a module description but no actual paramter for
> this.  I wish people would have listened to me back then and made the
> description part of the modular_param statement..
>   

Uh, what did I miss?  Oh, I see, I need a module_param(rx_mode, int,
0600) or something?  Or maybe with a callback if we can change it on the
fly?  And enum type?  Or maybe I string?

I'll sort it out.

>> +
>> +#define RX_COPY_THRESHOLD 256
>> +
>> +#define GRANT_INVALID_REF	0
>> +
>> +#define NET_TX_RING_SIZE __RING_SIZE((struct xen_netif_tx_sring *)0, PAGE_SIZE)
>> +#define NET_RX_RING_SIZE __RING_SIZE((struct xen_netif_rx_sring *)0, PAGE_SIZE)
>>     
>
> __RING_SIZE is not in my tree, so it seems to be some kind of Xen
> addition.  Can you make that clear in the name and give it a less
> awkware calling convention, e.g. only pass in the type, not a null
> pointer of the given type?
>   

Yeah.  The Xen ring stuff is a bit full of magic macros, so I was going
to look at inlineizing/re-namespacing it in a separate patch.

>> +/*
>> + * Implement our own carrier flag: the network stack's version causes delays
>> + * when the carrier is re-enabled (in particular, dev_activate() may not
>> + * immediately be called, which can cause packet loss).
>> + */
>> +#define netfront_carrier_on(netif)	((netif)->carrier = 1)
>> +#define netfront_carrier_off(netif)	((netif)->carrier = 0)
>> +#define netfront_carrier_ok(netif)	((netif)->carrier)
>>     
>
> This doesn't implement my review suggestion despite you ACKing
> them.  Didn't you like it in the end or did you simply forget
> about it?
>   

Sorry, I forgot about it.  I was waiting to hear back from network
people about what this is actually for, and whether we really need it. 
Rusty said in his review:
> Well, you only call netfront_carrier_on() from one place, so it's pretty
> easy to do "netif_carrier_on(); dev_activate();" there.
>
> I don't think this is critical though.
>   

It wasn't obvious to me whether this meant that we could avoid having a
netfront-private carrier flag but still get quick response by using
"netif_carrier_on(); dev_activate();".

    J
