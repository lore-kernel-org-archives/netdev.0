From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
	space data
Date: Sat, 20 Dec 2008 13:02:50 +1100
Message-ID: <20081220020250.GA15064@gondor.apana.org.au>
References: <494009D7.4020602@vlnb.net> <494012C4.7090304@vlnb.net> <494C0255.8010208@goop.org> <20081219220452.GB704@ioremap.net> <494C1E5E.7070809@goop.org> <20081219223314.GA2736@ioremap.net> <494C50BB.5030809@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Vladislav Bolkhovitin <vst@vlnb.net>,
	linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <494C50BB.5030809@goop.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 19, 2008 at 05:56:11PM -0800, Jeremy Fitzhardinge wrote:
> Evgeniy Polyakov wrote:
>> Shared info is freed when there are no skbs referring to the shared info
>> in question. Skb holds all pages in shared info in the fraglist array,
>> so when it is about to be freed, it means that network stack does not
>> use it (particulary it will putpage every page in fraglist). Usually
>> there are two skbs in the network stack per packet in TCP (allocated at
>> once though via fastclone mechanims): one is provided to the device
>> (and will be freed there) and another one is placed into retransmit
>> queue, where it will be located and freed when ack has been received.
>>
>> There may be another layers which may clone skb, but its shared info
>> structure (shared between the clones) will only be freed when all users
>> freed appropriate cloned skbs.

This is all correct.  However, please note that that if any clone
does a pskb_expand_head then it will get its own private copy of
of the shared info.  So you can't use the shared info to ref count
the pages in it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
