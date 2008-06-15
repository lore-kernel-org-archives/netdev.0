From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] firmware: convert e100 driver to
	request_firmware()
Date: Sun, 15 Jun 2008 19:30:31 -0400
Message-ID: <4855A617.90006@garzik.org>
References: <1213522966.26255.433.camel@pmac.infradead.org>	
	<48555677.7040209@garzik.org>	
	<3f9a31f40806151134n1b5e4de7m2ccd9c8a9e98cdb4@mail.gmail.com>	
	<485562F8.2000400@garzik.org>
	<1213567775.26255.534.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jaswinder Singh <jaswinderlinux@gmail.com>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1213567775.26255.534.camel@pmac.infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> On Sun, 2008-06-15 at 14:44 -0400, Jeff Garzik wrote:
>> Each driver is _intimately_ tied to its firmware, so it only increases
>> headaches by separating two pieces of a single, cohesive whole.
> 
> On reflection, that argument _does_ make me inclined to modify my
> approach.
> 
> The _only_ thing that lets us justify the inclusion of this firmware
> blob in the kernel in the first place is the rather tenuous claim that
> it is "mere aggregation on a volume of a storage or distribution medium"
> -- as if it's just some kind of coincidence that these two pieces of
> work happen to be shipped together.
> 
> If they really are "intimately tied pieces of a single, cohesive whole",
> as you say, then the claim that it's "mere aggregation on a volume of a
> storage or distribution medium" loses whatever small amount of
> credibility it had in the first place, and we have no option but to
> remove the offending part immediately.
> 
> Revised patch follows....
> 
>  drivers/net/Kconfig |    1 
>  drivers/net/e100.c  |  281 +++++++++++++++-------------------------------------
>  2 files changed, 86 insertions(+), 196 deletions(-)

So, in response you separate them further?  No thanks.

Put the data in drivers/net/e100.firmware.  It makes no sense to have 
two parallel driver hierarchies, one for C source and one for firmwares.

And IMO I would think the best first step for all such drivers would be 
to add request_firmware() support _without_ touching the embedded 
firmware.  You are trying to stuff too much change into a single patch.

Such a step gets most of your driver modifications into the kernel with 
the least headache and controversy, while adding the quite-useful 
ability to have a driver load an external firmware instead of the 
embedded one.

request_firmware() infrastructure addition is clearly a separate and 
distinct change from moving/removing an embedded firmware.

	Jeff




-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
