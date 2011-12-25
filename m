From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/2] igb: add PTP Hardware Clock
	code
Date: Sun, 25 Dec 2011 16:30:51 +0100
Message-ID: <20111225153050.GA2581@netboy.at.omicron.at>
References: <cover.1323744724.git.richardcochran@gmail.com>
	<382db16df224b31b126f26f0671cb5f67904e834.1323744725.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <382db16df224b31b126f26f0671cb5f67904e834.1323744725.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Just for the record, reviewing my own patch and pointing out the
mistakes WRT the 82576.

On Tue, Dec 13, 2011 at 04:00:34AM +0100, Richard Cochran wrote:
> +static void igb_82576_systim_write(struct igb_adapter *igb, u64 ns)
> +{
> +	u32 hi, lo;
> +	struct e1000_hw *hw = &igb->hw;
> +
> +	hi = (ns >> 8) & 0xffffffff;
> +	lo = (ns & 0xff) << NS_SHIFT_82576;

Should have been:

	hi = (ns >> 13) & 0xffffffff;
	lo = (ns & 0x1fff) << NS_SHIFT_82576;

> +
> +	wr32(E1000_SYSTIML, lo);
> +	wr32(E1000_SYSTIMH, hi);
> +
> +	igb_overflow_set(igb, ns, hi & SYSTIMH_MSB_82576, OFL_SHIFT_82576);
> +}

------------------------------------------------------------------------------
Write once. Port to many.
Get the SDK and tools to simplify cross-platform app development. Create 
new or port existing apps to sell to consumers worldwide. Explore the 
Intel AppUpSM program developer opportunity. appdeveloper.intel.com/join
http://p.sf.net/sfu/intel-appdev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
