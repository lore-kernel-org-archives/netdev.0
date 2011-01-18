From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool : Add option -L | --set-common to set common
 flags.
Date: Tue, 18 Jan 2011 02:59:55 +0000
Message-ID: <1295319595.3700.14.camel@localhost>
References: <1294963892-11997-1-git-send-email-maheshb@google.com>
	 <1295039984.5386.19.camel@bwh-desktop>
	 <AANLkTiko=12CLgG_MMPshfwSRt7mZA+3DW+GRtxhaxh=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38412 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385Ab1ARC77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 21:59:59 -0500
In-Reply-To: <AANLkTiko=12CLgG_MMPshfwSRt7mZA+3DW+GRtxhaxh=@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-17 at 18:17 -0800, Mahesh Bandewar wrote:
> On Fri, Jan 14, 2011 at 1:19 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Thu, 2011-01-13 at 16:11 -0800, Mahesh Bandewar wrote:
[...]
> >> +static int do_scommon(int fd, struct ifreq *ifr)
> >> +{
> >> +     struct ethtool_value eval;
> >> +
> >> +     if (common_flags_mask) {
> >> +             eval.cmd = ETHTOOL_GFLAGS;
> >> +             eval.data = 0;
> >> +             ifr->ifr_data = (caddr_t)&eval;
> >> +             if (ioctl(fd, SIOCETHTOOL, ifr)) {
> >> +                     perror("Cannot get device common flags");
> >> +                     return 1;
> >> +             }
> >> +
> >> +             eval.cmd = ETHTOOL_SFLAGS;
> >> +             eval.data =
> >> +                 ((eval.data & ~(common_flags_mask | off_flags_mask)) |
> >> +                  (common_flags_wanted | off_flags_wanted));
> >
> > Why should this use off_flags_mask and off_flags_wanted?  They should
> > both be 0 if this function is called.
> >
> That is right! Actually the get (ETHTOOL_GFLAGS) operation confused
> me. I thought the values are fetched and *preserved* while setting the
> new value. But when looked at it carefully, that is not the case.
> Actually why that ioctl() with ETHTOOL_GFLAGS required?
[...]

This is a read-modify-write operation.  We have to:

1. Parse the options to find out which flags are to be changed
(common_flags_mask) and the wanted values (common_flags_wanted).
2. Read the current flags (ETHTOOL_GFLAGS reads them into eval.data).
3. Modify the flags (eval.data = ...).
4. Write the new flags (ETHTOOL_SFLAGS).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

