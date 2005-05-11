From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: Add hw coalescing infrastructure.
Date: Wed, 11 May 2005 14:17:36 -0700
Message-ID: <1115846256.8570.109.camel@rh4>
References: <20050511.141530.57445142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050511.141530.57445142.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-05-11 at 14:15 -0700, David S.Miller wrote:

> It seems that we should also be avoiding the HOSTCC_{R,T}XCOAL_MAXF_INT
> registers when TG3_FLG2_5705_PLUS.  I didn't make that change yet, just
> preserving what we were doing previously.

These registers are still defined for 5705_PLUS chips, only the maximum
value has been reduced to 255. So we're ok.

> 
> Another thing which occurred to me is that these settings are line
> rate dependant.  For example, the 20 usec value is for gigabit.
> So we may wish to adjust the values we use based upon the negotiated
> line speed.   But that's a future refinement that can wait.
> 
Yes, and MTU size dependent too. But we may not want to coalesce the
same way when running at 10/100 Mbps. For example, if one packet has
arrived, we don't want to wait 120 usec or 1200 usec to see if another
packet will arrive before we interrupt at 100 and 10 Mbps respectively.

> I think with the removal of that I/O readback done by the tagged
> status changes, and this coalescing stuff below, the SGI NUMA
> performance should be significantly higher.
> 
> Comments?

Other than adding a check for netif_carrier_ok() before setting the
HOSTCC_STAT_COAL_TICKS register in tg3_set_coalesce(), everything looks
good to me.
