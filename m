From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH v2 1/6] net-PPP: Replacement of a printk() call by
 pr_warn() in mppe_rekey()
Date: Fri, 5 Dec 2014 08:21:15 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1412050820290.2059@localhost6.localdomain6>
References: <1417731809.2721.17.camel@perches.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417731809.2721.17.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 4 Dec 2014, Joe Perches wrote:

> On Thu, 2014-12-04 at 23:10 +0100, SF Markus Elfring wrote:
> > The mppe_rekey() function contained a few update candidates.
> > * Curly brackets were still used around a single function call "printk".
> > * Unwanted space characters
> > 
> > Let us improve these implementation details according to the current Linux
> > coding style convention.
> 
> trivia:
> 
> > diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
> []
> > @@ -172,9 +172,8 @@ static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
> >  		setup_sg(sg_in, state->sha1_digest, state->keylen);
> >  		setup_sg(sg_out, state->session_key, state->keylen);
> >  		if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in,
> > -					     state->keylen) != 0) {
> > -    		    printk(KERN_WARNING "mppe_rekey: cipher_encrypt failed\n");
> > -		}
> > +					     state->keylen) != 0)
> > +			pr_warn("mppe_rekey: cipher_encrypt failed\n");
> 
> It's generally nicer to replace embedded function names
> with "%s: ", __func__
> 
> 			pr_warn("%s: cipher_encrypt failed\n", __func__);

Doing so may potentially allow some strings to be shared, thus saving a 
little space.  Perhaps not in this case, though.

julia
