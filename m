From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 5/5] r8169: ethtool hardware statistics support
Date: Wed, 9 Mar 2005 22:21:48 -0600
Message-ID: <200503092221.48487.jdmason@us.ibm.com>
References: <20050309113626.6708c93e@dxpl.pdx.osdl.net> <200503091537.30899.jdmason@us.ibm.com> <20050309135345.5efae9b6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050309135345.5efae9b6@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 09 March 2005 03:53 pm, Stephen Hemminger wrote:
> On Wed, 9 Mar 2005 15:37:30 -0600
>
> Jon Mason <jdmason@us.ibm.com> wrote:
> > Does this patch fix the problem of bogus statistics if the interface is
> > down
>
> I see no problem when interface is down. It returns all zero's because
> the device is reset on probe (and on shutdown).

I can confirm that I see no statistic errors either. 

I believe the faulty code in Richard's patch was:
+       if (RTL_R32(StatsAddrLow) & DumpStats)
+               return; /* no stats - took too long */

Which returned before the stats were populated (leaving garbage).  Since your 
patch lacks this, we see no problem.  If this is true, there is probably a 
problem on 8139cp, which has a similar error path in its cp_get_ethtool_stats 
function.   

Thanks,
Jon
