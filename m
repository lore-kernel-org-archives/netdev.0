From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Fix possible dev_deactivate race condition
Date: Fri, 19 Oct 2007 17:29:21 +0800
Message-ID: <20071019092921.GA12380@gondor.apana.org.au>
References: <1192745137.7367.40.camel@pasglop>
	<alpine.LFD.0.999.0710181549330.26902@woody.linux-foundation.org>
	<1192749449.7367.51.camel@pasglop>
	<alpine.LFD.0.999.0710181627091.26902@woody.linux-foundation.org>
	<20071019023219.GB8453@gondor.apana.org.au>
	<alpine.LFD.0.999.0710181941020.26902@woody.linux-foundation.org>
	<alpine.LFD.0.999.0710182007170.26902@woody.linux-foundation.org>
	<20071019042025.GA9617@gondor.apana.org.au>
	<20071019053624.GA10560@gondor.apana.org.au>
	<1192779319.27435.163.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1192779319.27435.163.camel@twins>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 09:35:19AM +0200, Peter Zijlstra wrote:
>
> >         /* Wait for outstanding qdisc_run calls. */
> > -       while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
> > -               yield();
> > +       do {
> > +               while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
> > +                       yield();
> > +
> 
> Ouch!, is there really no sane locking alternative? Hashed waitqueues
> like for the page lock come to mind.

Well if we ever moved the transmission to full process context
then we'll gladly accept your patch :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
