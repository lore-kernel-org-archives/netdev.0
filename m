From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Wed, 30 May 2007 21:51:14 -0700
Message-ID: <465E5442.7010503@intel.com>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>
	<465E0149.6030307@intel.com>
	<20070531005147.GA30628@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Doug Chapman <doug.chapman@hp.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070531005147.GA30628@gondor.apana.org.au>
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

Herbert Xu wrote:
> On Wed, May 30, 2007 at 03:57:13PM -0700, Kok, Auke wrote:
>> Hmm, we're making a mess of it.
> 
> Indeed :)
> 
>> Herbert, wouldn't it just have been a lot easier to do just add a 
>> netif_poll_disable in e1000_probe, so that any and all other poll 
>> enable/disables are symmetric ? Something like this?
> 
> I wish if it were as simple as that.  As soon as register_netdev
> returns somebody else can invoke e1000_open so disabling poll
> here can be undesirable.  In fact the existing netif_stop_queue
> and netif_carrier_off calls are also bad for the same reason.

this has been an age-old confusion that I never grasped either, so I perfectly 
understand why you added the explicit e1000_disable_irq call in the other patch 
(and think thats a great idea). But really, there should be a way for a driver 
to tell the stack that it should really keep it's hands off :)

BTW e1000 currently triggers a single irq manually in the watchdog as link goes 
up, so that might be the one that is giving problems now. In any case I can't 
reproduce any of it - perhaps my hardware is too fast. Time to whip out the pIII :o

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
