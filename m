From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH ethtool] Add the command to show the time
 stamping capabilities.
Date: Tue, 3 Apr 2012 07:37:17 +0200
Message-ID: <20120403053717.GA2155@netboy.at.omicron.at>
References: <1333293808-7729-1-git-send-email-richardcochran@gmail.com>
	<1333394758.5356.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1333394758.5356.28.camel@bwh-desktop.uk.solarflarecom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Apr 02, 2012 at 08:25:58PM +0100, Ben Hutchings wrote:
> On Sun, 2012-04-01 at 17:23 +0200, Richard Cochran wrote:

> > +	if (info->tx_types & (1 << HWTSTAMP_TX_OFF))
> > +		fprintf(stdout, "HWTSTAMP_TX_OFF\n");
> > +
> > +	if (info->tx_types & (1 << HWTSTAMP_TX_ON))
> > +		fprintf(stdout, "HWTSTAMP_TX_ON\n");
> > +
> > +	if (info->tx_types & (1 << HWTSTAMP_TX_ONESTEP_SYNC))
> > +		fprintf(stdout, "HWTSTAMP_TX_ONESTEP_SYNC\n");
> 
> If there is no hardware timestamping available then shouldn't we see
> HWTSTAMP_TX_OFF reported here?  But that's going to be the case.  Not
> sure whether the kernel or the ethtool utility should deal with that,
> but don't assume the ethtool utility is the only consumer.

Actually, if the device does not support hardware time stamping at
all, then ioctl SIOCSHWTSTAMP returns EOPNOTSUPP. So, HWTSTAMP_TX_ON
means you can turn Tx time stamping on, and HWTSTAMP_TX_OFF means you
can turn it off again. It might not seem too logical, but that is how
the interface works.

So (tx_types == 0) means no hardware timestamping available. We can
print that as a special case, if you think it best.

> Hardware Receive Filter Modes:
> 	none (HWTSTAMP_FILTER_NONE)
> 	ptpv2-l4-event (HWTSTAMP_FILTER_PTP_V2_L4_EVENT)
> 	ptpv2-l4-sync (HWTSTAMP_FILTER_PTP_V2_L4_SYNC)
> 
> (Maybe you can think of better names.)

Okay, I get the idea.

Thanks,
Richard

------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
