From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Thu, 27 Mar 2008 15:47:28 -0700
Message-ID: <47EC2400.50602@intel.com>
References: <20080326183631.25114.90265.stgit@localhost.localdomain>
	<47EA9911.8040101@garzik.org> <47EAB54A.1060306@intel.com>
	<36D9DB17C6DE9E40B059440DB8D95F5204BF07F7@orsmsx418.amr.corp.intel.com>
	<20080327220527.GO856@gospo.usersys.redhat.com>
	<47EC1CC9.5080305@intel.com>
	<20080327223337.GP856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	"Kok,  Auke" <auke-jan.h.kok@intel.com>,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	Jeff Garzik <jeff@garzik.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080327223337.GP856@gospo.usersys.redhat.com>
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

Andy Gospodarek wrote:
> On Thu, Mar 27, 2008 at 03:16:41PM -0700, Kok, Auke wrote:
>> Andy Gospodarek wrote:
>>> On Thu, Mar 27, 2008 at 10:53:43AM -0700, Brandeburg, Jesse wrote:
>>>> Kok, Auke wrote:
>>>>> Jeff Garzik wrote:
>>>>>> Auke Kok wrote:
>>>>>>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>>>>>>
>>>>>>> Test the MSI interrupt physically once before assuming that it
>>>>>>> actually works. Several platforms have already come across that
>>>>>>> have non-functional MSI interrupts and this code will attempt
>>>>>>> to detect those safely. Once the test succeeds MSI interrupts
>>>>>>> will be enabled.
>>>>>>>
>>>>>>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>>>>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>>>>> Ah, the perennial add-same-test-to-every-driver conundrum.
>>>>>>
>>>>>> I think we are far enough along with MSI to _not_ do this anymore in
>>>>>> drivers. 
>>>> Actually, I'm hoping you'll allow this Jeff, we have a production system
>>>> (see below) we know about that doesn't like the way 82571 formats MSI
>>>> interrupt messages.  All other systems seem to be okay with this format
>>>> of MSI messages, but this system implemented a stricter interpretation
>>>> of the spec, and so even though that system doesn't need a quirk for MSI
>>>> because MSI works in general, we still MUST test the MSI vector to make
>>>> sure it works *for us*  In this case it comes down to being an errata
>>>> workaround.
>>>>
>>>> Since there is no way to "test" generation of an interrupt from any
>>>> specific hardware device without internal knowledge of said device,
>>>> there isn't a way for us to help the kernel by writing a generic "test
>>>> MSI" routine.
>>>>
>>>> I would prefer this "generic test" code be in the driver rather than
>>>> having to identify all the chipsets that fail and have the driver do
>>>> *specific chipset* detection ala bnx2.c's 8132 bridge workaround.
>>>>
>>>>>> The platforms with MSI problems should be discovered, made public,
>>>>>> and worked around. 
>>>> This is our workaround, it is our fault, the incompatible chipset is in
>>>> an x3850 IBM system.
>>>>
>>> I've seem similar problems on other systems, so this would be a nice bit
>>> of code to have somewhere.  I can see Jeff's argument for having this
>>> outside of drivers, but to make my life easier I'd like to see this in
>>> e1000e (and e1000!).  :-)
>> e1000 will soon no longer support PCI Express devices, so this is unneeded.
>>
> 
> So you plan to drop the bits around the device additions that are
> related to e1000e config sometime soon?

yes I was hoping to do this for 2.6.26 already, if not 2.6.27.

I definately don't want to have that linger.

Auke


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
