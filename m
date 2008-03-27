From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 15:43:42 -0400
Message-ID: <47EBF8EE.1000102@garzik.org>
References: <20080326183631.25114.90265.stgit@localhost.localdomain>
	<47EA9911.8040101@garzik.org> <47EAB54A.1060306@intel.com>
	<36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Kok,  Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com>
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

Brandeburg, Jesse wrote:
> Kok, Auke wrote:
>> Jeff Garzik wrote:
>>> Auke Kok wrote:
>>>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>>>
>>>> Test the MSI interrupt physically once before assuming that it
>>>> actually works. Several platforms have already come across that
>>>> have non-functional MSI interrupts and this code will attempt
>>>> to detect those safely. Once the test succeeds MSI interrupts
>>>> will be enabled.
>>>>
>>>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
>>> Ah, the perennial add-same-test-to-every-driver conundrum.
>>>
>>> I think we are far enough along with MSI to _not_ do this anymore in
>>> drivers. 
> 
> Actually, I'm hoping you'll allow this Jeff, we have a production system
> (see below) we know about that doesn't like the way 82571 formats MSI
> interrupt messages.  All other systems seem to be okay with this format
> of MSI messages, but this system implemented a stricter interpretation
> of the spec, and so even though that system doesn't need a quirk for MSI
> because MSI works in general, we still MUST test the MSI vector to make
> sure it works *for us*  In this case it comes down to being an errata
> workaround.
> 
> Since there is no way to "test" generation of an interrupt from any
> specific hardware device without internal knowledge of said device,
> there isn't a way for us to help the kernel by writing a generic "test
> MSI" routine.
> 
> I would prefer this "generic test" code be in the driver rather than
> having to identify all the chipsets that fail and have the driver do
> *specific chipset* detection ala bnx2.c's 8132 bridge workaround.

Well if it's a problem with the networking chip rather than the 
platform, then absolutely stick it in the driver (unless its so severe 
it needs to be in pci/quirks.c before the driver even loads).

But that seems like a quick id test, with no need for all that generic 
MSI test code.

Certainly the work is scoped based on where the problem lies, either 
platform, device, or platform+device.

	Jeff




-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
