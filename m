From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH net] igb: Unset IGB_FLAG_HAS_MSIX-flag
 when falling back to msi-only
Date: Wed, 19 Feb 2014 00:05:30 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73157E74@ORSMSX101.amr.corp.intel.com>
References: <1392766595-14454-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1392766595-14454-1-git-send-email-christoph.paasch@uclouvain.be>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2014-02-19 at 00:36 +0100, Christoph Paasch wrote:
> rior to cd14ef54d25 (igb: Change to use statically allocated array for
> MSIx entries), having msix_entries different from NULL was an
> indicator
> that MSIX is enabled.
> In igb_set_interrupt_capabiliy we may fall back to MSI-only. Prior to
> the above patch msix_entries was set to NULL by
> igb_reset_interrupt_capability.
> 
> However, now we are checking the flag for IGB_FLAG_HAS_MSIX and so the
> stack gets completly confused:
> 
> [   42.659791] ------------[ cut here ]------------
> <snip>

> [   47.892146] handlers:
> [   47.919301] [<ffffffff812fbd7d>] igb_intr
> 
> So, this patch unsets the flag to indicate that we are not using MSIX.
> This patch does exactly this: Unsetting the flag when falling back to
> MSI.
> 
> Fixes: cd14ef54d25b (igb: Change to use statically allocated array for
> MSIx entries)
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 1 +
>  1 file changed, 1 insertion(+) 

Thanks Christoph, I have added this to our Jeff's internal queue as
well.
------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121054471&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
