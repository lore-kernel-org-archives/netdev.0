From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [QUESTION] multi-core, multi-crypto,  ipsec/udp out of order.
Date: Mon, 2 Jun 2014 20:46:49 +0800
Message-ID: <20140602124649.GA2503@gondor.apana.org.au>
References: <A83C99F8370D4D42BEB2D2B3153A6BBC30807AE1@NASANEXD02C.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: "Hsieh, Che-Min" <cheminh@qti.qualcomm.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <A83C99F8370D4D42BEB2D2B3153A6BBC30807AE1@NASANEXD02C.na.qualcomm.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 30, 2014 at 02:22:17PM +0000, Hsieh, Che-Min wrote:
> Hi! Herbert:
> 
>   In a system of multi cpu core, with multiple crypto hardware, different irq for each, is it possible the udp receive get out of order for the same tfm?
>  
> Let us say, of the same tfm, driver distributes requests to any available crypto hardware.  For the same tfm, driver re-sequences response before complete callout to the same arrival sequence of the requests. The complete callout is running at tasklet level of the system.
> 
> Each irq is assigned to a different irq affinity cpu core to improve the performance. Therefore the iprecv and ipsec processing can be done by multiple cpu cores at the same time for the same tfm/udp.
> 
> I am seeing the following -   if I assign irq affinity to different cpu cores, iperf server of udp session displays receive out of order message. If I assign them to the same core, or take default, then message stops. The assignment is done by hand while the system is running, by updating  /proc/irq/xxx/smp_affinity, where xxx is the irq number. This scenario is very repeatable. 
> 
> We are on linux-3.10.
> 
> Does it make sense?

Are we talking about an in-tree driver? If so which one?

It's not certainly not meant to change packet ordering.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
