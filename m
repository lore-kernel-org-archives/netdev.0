From: "Hsieh, Che-Min" <cheminh@qti.qualcomm.com>
Subject: RE: [QUESTION] multi-core, multi-crypto,  ipsec/udp out of order.
Date: Tue, 3 Jun 2014 13:48:56 +0000
Message-ID: <A83C99F8370D4D42BEB2D2B3153A6BBC30808594@NASANEXD02C.na.qualcomm.com>
References: <A83C99F8370D4D42BEB2D2B3153A6BBC30807AE1@NASANEXD02C.na.qualcomm.com>
 <20140602124649.GA2503@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"Bronstein, Dan" <dbronste@qti.qualcomm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20140602124649.GA2503@gondor.apana.org.au>
Content-Language: en-US
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert:
Sorry, what is "in-tree" driver? This is Qcom crypto driver. It is part of android linux 3-10. I think Stanimir Varbanov is working on upstreaming the crypto driver. The driver version he cuts off, does static crypto engine assignment, i.e. crypto HW is assigned to a TFM on  cra_init. That scheme is simple. But, under the same TFM, it does not take advantage of multiple crypto HW working in parallel. Later, we put in dynamic engine assignment per request, as described in the previous mail thread.

I am trying to understand why we are seeing iperf server out of order message once we have different cores assigned to crypto irq affinity. 

Thanks.

Chemin

-----Original Message-----
From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
Sent: Monday, June 02, 2014 8:47 AM
To: Hsieh, Che-Min
Cc: linux-crypto@vger.kernel.org; netdev@vger.kernel.org; Steffen Klassert
Subject: Re: [QUESTION] multi-core, multi-crypto, ipsec/udp out of order.

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
Email: Herbert Xu <herbert@gondor.apana.org.au> Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
