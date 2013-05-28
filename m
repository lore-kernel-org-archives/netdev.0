From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: igb: acknowledging time sync interrupts
Date: Tue, 28 May 2013 15:20:10 +0000
Message-ID: <CDCA1885.1E850%matthew.vick@intel.com>
References: <20130526103900.GA11682@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130526103900.GA11682@netboy>
Content-Language: en-US
Content-ID: <37DA2C9227E386448FD57345EDF352E5@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 5/26/13 3:39 AM, "Richard Cochran" <richardcochran@gmail.com> wrote:

>Matt,
>
>In igb_main.c you have ISR code like:
>
>	if (icr & E1000_ICR_TS) {
>		u32 tsicr = rd32(E1000_TSICR);
>
>		if (tsicr & E1000_TSICR_TXTS) {
>			/* acknowledge the interrupt */
>			wr32(E1000_TSICR, E1000_TSICR_TXTS);
>			/* retrieve hardware timestamp */
>			schedule_work(&adapter->ptp_tx_work);
>		}
>	}
>
>In the datasheet for the 82580 and the i210, for TSICR it says,
>
>   Note: Once ICR.Time_Sync is set, the internal value of this
>         register should be cleared by writing 1b to all bits
>         or cleared by a read to enable receiving an additional
>         ^^^^^^^^^^^^^^^^^^^^
>         ICR.Time_Sync interrupt.
>
>and that implies that your write to acknowledge the interrupt is
>superfluous, since you already read the TSICR.
>
>Is this an error in the datasheets, or is the code doing extra,
>unneeded work?
>
>Thanks,
>Richard

Richard,

Good catch--and you're correct--but I had issues with the read of TSICR
not clearing like it should on the 82580 (but it would work fine on the
I350 and I210). I decided the cleaner implementation would be to
explicitly acknowledge the interrupt across the board. I haven't had the
time to follow up with the hardware team, but my suspicion is that it's an
errata with the 82580.

I'll start some internal discussion to see if I can get an official answer
on the 82580.

Cheers,
Matthew


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
