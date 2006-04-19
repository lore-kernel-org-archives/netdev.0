From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [TCP]: Fix truesize underflow
Date: Wed, 19 Apr 2006 09:53:48 -0700
Message-ID: <20060419095348.0de93eaf@localhost.localdomain>
References: <20060418123204.GA3962@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Boris B. Zhmurov" <bb@kernelpanic.ru>,
	Phil Oester <kernel@linuxace.com>,
	Mark Nipper <nipsy@bitgnome.net>,
	"David S. Miller" <davem@davemloft.net>,
	jesse.brandeburg@intel.com, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	Andi Kleen <ak@suse.de>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:29124 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751002AbWDSQzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 12:55:04 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060418123204.GA3962@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Apr 2006 22:32:04 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Dave:
> 
> You're absolutely right about there being a problem with the TSO packet
> trimming code.  The cause of this lies in the tcp_fragment() function.
> 
> When we allocate a fragment for a completely non-linear packet the
> truesize is calculated for a payload length of zero.  This means that
> truesize could in fact be less than the real payload length.
> 
> When that happens the TSO packet trimming can cause truesize to become
> negative.  This in turn can cause sk_forward_alloc to be -n * PAGE_SIZE
> which would trigger the warning.
> 
> I've copied the code you used in tso_fragment which should work here.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Everyone who's having the sk_forward_alloc warning problem should give
> this patch a go to see if it cures things.
> 
> Just in case this still doesn't fix it, could everyone please also verify
> whether disabling SMP has any effect on reproducing this?
> 
> Thanks,

Please put this in the next -stable load...
