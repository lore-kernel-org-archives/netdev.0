From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 5/5] r8169: ethtool hardware statistics support
Date: Thu, 10 Mar 2005 12:00:55 -0800
Message-ID: <20050310120055.5991e354@dxpl.pdx.osdl.net>
References: <20050309113626.6708c93e@dxpl.pdx.osdl.net>
	<200503091537.30899.jdmason@us.ibm.com>
	<20050309135345.5efae9b6@dxpl.pdx.osdl.net>
	<200503092221.48487.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200503092221.48487.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Mar 2005 22:21:48 -0600
Jon Mason <jdmason@us.ibm.com> wrote:

> On Wednesday 09 March 2005 03:53 pm, Stephen Hemminger wrote:
> > On Wed, 9 Mar 2005 15:37:30 -0600
> >
> > Jon Mason <jdmason@us.ibm.com> wrote:
> > > Does this patch fix the problem of bogus statistics if the interface is
> > > down
> >
> > I see no problem when interface is down. It returns all zero's because
> > the device is reset on probe (and on shutdown).
> 
> I can confirm that I see no statistic errors either. 
> 
> I believe the faulty code in Richard's patch was:
> +       if (RTL_R32(StatsAddrLow) & DumpStats)
> +               return; /* no stats - took too long */
> 
> Which returned before the stats were populated (leaving garbage).  Since your 
> patch lacks this, we see no problem.  If this is true, there is probably a 
> problem on 8139cp, which has a similar error path in its cp_get_ethtool_stats 
> function.   

The problem with the 8139cp is that it allocates the area to hold
the statistics as part of the ring structure. The ring structure doesn't
exist until device is up.

I figured that there was no point in holding the extra space unless needed.
One more brief pci allocation was easier.  Also, my code waits longer
(up to 10ms) and is CPU speed independent.

Should I go back and fix the 8139cp?
