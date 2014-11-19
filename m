From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: net: xfrm: Deletion of an unnecessary check before the function
 call "ipcomp_free_tfms"
Date: Wed, 19 Nov 2014 10:58:01 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1411191054410.2363@hadrien>
References: <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.sourceforge.net> <546BAFF5.5020603@users.sourceforge.net> <20141119084542.GK4905@mwanda> <546C6823.50900@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <546C6823.50900@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 19 Nov 2014, SF Markus Elfring wrote:

> >> The ipcomp_free_tfms() function tests whether its argument is NULL and then
> >> returns immediately. Thus the test around the call is not needed.
> >
> > It doesn't though...
>
> You are right that this function implementation does a bit more before
> returning because of a detected null pointer.
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/net/xfrm/xfrm_ipcomp.c?id=394efd19d5fcae936261bd48e5b33b21897aacf8#n247
>
> Can you agree that input parameter validation is also performed there?
> Do you want that I resend my patch with a corrected commit message?

This is completely crazy.  The function performs a side effect on a data
structure.  If the call site doesn't want that done in a certain case,
then it should not be done.

julia
