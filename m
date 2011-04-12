From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
 physical identification
Date: Tue, 12 Apr 2011 17:28:06 +0100
Message-ID: <1302625686.2880.24.camel@bwh-desktop>
References: <20110411231635.9339.36369.stgit@gitlad.jf.intel.com>
	 <20110411162601.6686f169@nehalam>
	 <8DD2590731AB5D4C9DBF71A877482A90018A2A30A9@orsmsx509.amr.corp.intel.com>
	 <1302566453.5282.585.camel@localhost>
	 <8DD2590731AB5D4C9DBF71A877482A90018A2A315B@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28323 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755947Ab1DLQ2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 12:28:10 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90018A2A315B@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-11 at 18:07 -0700, Allan, Bruce W wrote:
> >-----Original Message-----
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Monday, April 11, 2011 5:01 PM
> >To: Allan, Bruce W
> >Cc: Stephen Hemminger; netdev@vger.kernel.org
> >Subject: RE: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for
> >physical identification
> >
> >I noticed that some drivers did this.  Do you know if these OEMs expect
> >this of all hardware, or do they actually want different vendors'
> >hardware to blink in different ways?  If it's a common requirement to
> >blink at 2 Hz then let's use that frequency for all the drivers that
> >want to be called periodically.
> >
> >Ben.
> 
> Sorry, I don't know.  I'll ask around, but doubt I will get a definitive
> answer.

I enquired here and found that we do have an OEM specifying 1 Hz.

> FWIW, without digging too deep into how other drivers identify their
> respective ports through software, it appears it was split:
> * bnx2*, cxgb3, niu, s2io, sfc, sky2, tg3 - once per second
> * e100*, igb, ixgb*, pcnet32, ewrk3, cxgb4 - approx. twice per second
>
> AFAIK for parts that can set the physical identification through hardware,
> the Intel drivers set the on/off intervals to approximately twice/second;
> I don't know what other drivers do in that situation.
> 
> So, I would guess it is not a common requirement to blink at a specific Hz.
> I have no problem with changing the hard-coded blink frequency to what our
> OEMs expect, but that might be an issue for those other vendors; I was just
> trying to make it flexible.

Sadly it appears this is necessary.

Let's define the return value for drivers wanting periodic callbacks to
be the blink frequency in Hz (normally 1 or 2), and get rid of the
special case of -EINVAL.  This also removes the rather inelegant
semantic that drivers may need to change their state despite returning
an error code.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

