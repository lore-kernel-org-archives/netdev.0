From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/8] e1000e: cleanup several stats issues
Date: Mon, 28 Apr 2008 15:13:22 -0700
Message-ID: <48164C02.9060902@intel.com>
References: <20080423180900.24972.84015.stgit@localhost.localdomain>
	<481173B9.3010006@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <481173B9.3010006@garzik.org>
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

Jeff Garzik wrote:
> Auke Kok wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>>
>> Several stats registers are completely unused and we just waste pci
>> bus time reading them. We also omit using the high 32 bits of the GORC/
>> GOTC counters. We can just read clear them and only read the low
>> registers.
>>
>> Mii-tool can also break es2lan if it executes a MII PHY register
>> ioctl while the device is in autonegotiation. Unfortunately it seems
>> that several applications and installations still perform this ioctl
>> call periodically and especially in this crucial startup time. We
>> can fool the ioctl by providing fail safe information that mimics
>> the "down" link state and only perform the dangerous PHY reads once
>> after link comes up to fill in the real values. As long as link
>> stays up the information will not change.
>>
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> applied 1-8
> 
> I was mainly waiting for the discussion of the abuse of the ethtool
> interface, which I chose to allow.
> 
> Now, send me a patch to the ethtool man page for this new behavior :)

it almost seems more appropriate to send a patch to the e1000 README and explain
the parameter use in there since this is a per-driver modification and there's
nothing special about the ethtool call itself.

Would you be OK with a general patch to ethtool that states that "drivers may
interpret values differently and users should consult the driver's source code or
README for proper use of the parameter." ?

This seems the logical solution.

Auke


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
