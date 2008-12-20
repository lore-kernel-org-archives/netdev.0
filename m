From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH][RFC 23/23]: Support for zero-copy TCP transmit of user
 space data
Date: Sat, 20 Dec 2008 11:39:18 -0800
Message-ID: <494D49E6.9000703@goop.org>
References: <494C0255.8010208@goop.org> <20081219220452.GB704@ioremap.net> <494C1E5E.7070809@goop.org> <20081219223314.GA2736@ioremap.net> <494C50BB.5030809@goop.org> <20081220020250.GA15064@gondor.apana.org.au> <494C8D57.7040808@goop.org> <20081220065105.GA16936@gondor.apana.org.au> <494CA226.9000200@goop.org> <20081220081045.GA17439@gondor.apana.org.au> <20081220103209.GA23632@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
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
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20081220103209.GA23632@ioremap.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Things should work fine, since pskb_expand_head() copies whole shared
> info structure (and thus will copy destructor), get all pages and then
> copy all pointers into the new skb, and then release old skb's data.
>
> So destructor for the pages should not rely on which skb it is called on
> and check if pages are about to be really freed (i.e. check theirs
> reference counter).
>   

OK.

> __pskb_pull_tail() is tricky, it just puts some pages it does not want
> to be present in the skb, but it could be possible to add there
> destructor callback from the original skb with partial flag (or just
> having destructor with two parameters: skb and page, and if page is not
> NULL, then actually only given page is freed, otherwise the whole skb).
>   

Yes, that doesn't sound too bad.

    J
