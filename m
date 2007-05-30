From: Doug Chapman <doug.chapman@hp.com>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Wed, 30 May 2007 19:31:31 -0400
Message-ID: <1180567891.23536.1.camel@athlon>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>
	<465E0149.6030307@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, doug.chapman@hp.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <465E0149.6030307@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-30 at 15:57 -0700, Kok, Auke wrote:
> Doug Chapman wrote:
> > All,
> > 
> > I reported this a few weeks ago and it was fixed but it appears the
> > offending code was again re-submitted.  This causes a panic on HP
> > Integrity servers and from what I hear many other platforms using e1000
> > as well.
> > 
> > My original report was via kernel.org BZ:
> > http://bugzilla.kernel.org/show_bug.cgi?id=8455
> > 
> > I am seeing the same panic with a kernel built from today's git pull.
> > 
> > 
> > It was fixed by this commit:
> > 3e1657c8ef53e1cd541cc1e420f3230dc075949b
> > 
> > 
> > but once again broken just yesterday by the following commit.  I have
> > backed just this commit out and verified I no longer panic.
> > 
> > 
> > commit 47313054352b879a2bc65379d55b05f48a0af7ec
> > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > Date:   Tue May 29 15:07:31 2007 -0700
> > 
> >     e1000: restore netif_poll_enable call but make sure IRQs are off
> 
> Hmm, we're making a mess of it.
> 
> Herbert, wouldn't it just have been a lot easier to do just add a 
> netif_poll_disable in e1000_probe, so that any and all other poll 
> enable/disables are symmetric ? Something like this?
> 
> Auke
> 
> 
> PS: apologies for the whitespace damage... it's a cut'n'paste
> ---
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 49be393..a8a3c5f 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1149,6 +1149,7 @@ e1000_probe(struct pci_dev *pdev,
>          /* tell the stack to leave us alone until e1000_open() is called */
>          netif_carrier_off(netdev);
>          netif_stop_queue(netdev);
> +       netif_poll_disable(netdev);
> 
>          DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");

Auke,

I tested this and it does indeed fix the panic on my systems.  I will
leave the decision as to if it is the "right" thing to do to those who
are more knowledgeable with the code.

- Doug



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
