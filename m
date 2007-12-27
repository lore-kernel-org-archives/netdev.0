From: David Miller <davem@davemloft.net>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Thu, 27 Dec 2007 00:57:25 -0800 (PST)
Message-ID: <20071227.005725.144782426.davem@davemloft.net>
References: <20071221.205808.213484078.davem@davemloft.net>
	<20071227173802.6F56.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: mokuno@sm.sony.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58427
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751471AbXL0I50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 03:57:26 -0500
In-Reply-To: <20071227173802.6F56.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Date: Thu, 27 Dec 2007 17:51:49 +0900

> 	Hi
> 
> On Fri, 21 Dec 2007 20:58:08 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > @@ -520,7 +530,7 @@ iwe_stream_add_point(char *	stream,		/* Stream of events */
> >  		memcpy(stream + IW_EV_LCP_LEN,
> >  		       ((char *) iwe) + IW_EV_LCP_LEN + IW_EV_POINT_OFF,
> >  		       IW_EV_POINT_PK_LEN - IW_EV_LCP_PK_LEN);
> 
> As the alignment of 64bit platforms may be defferent from 32bit one,
> should it be like the following?

IW_EV_LCP_LEN is the same on both 32-bit and 64-bit platforms, it is
just the size of the "len" and "cmd" portions of struct iw_event.

Those are both __u16, so IW_EV_LCP_LEN always evaluates to "4",
try it if you do not believe me. :-)

The iwreq_data size is invariant across the calculations.
If it's bigger on 64-bit, more will be subtracted in the
calculation performed by IW_EV_LCP_LEN.

So my patches are correct as-is and we do not need to
be mindful of compat'ness wrt. IW_EV_LCP_LEN.
