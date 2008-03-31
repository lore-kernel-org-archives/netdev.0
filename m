From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] [Syncookies:] Add support for TCP-options via
	timestamps.
Date: Mon, 31 Mar 2008 23:00:33 +0200
Message-ID: <20080331210033.GA27117@Chamillionaire.breakpoint.cc>
References: <1206922182-2214-1-git-send-email-fw@strlen.de> <47f12aa2.0d87460a.31a3.ffff8345@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:55410 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755106AbYCaVAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 17:00:34 -0400
Received: id: fw by Chamillionaire.breakpoint.cc with local
	(easymta 1.00 BETA 1)
	id 1JgR7J-0000HB-7u
	for netdev@vger.kernel.org; Mon, 31 Mar 2008 23:00:33 +0200
Content-Disposition: inline
In-Reply-To: <47f12aa2.0d87460a.31a3.ffff8345@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glenn Griffin <ggriffin.kernel@gmail.com> wrote:
> > +	u32 ts, ts_now = tcp_time_stamp;
> > +
> > +	if (unlikely(options > ts_now)) { /* recent overflow */
> > +		options |= ~(TSMASK);
> > +		return options;
> > +	}
> > +	ts = ts_now & ~TSMASK;
> > +	ts |= options;
> > +	if (ts > ts_now) { /* try to fix up ... */
> > +		ts >>= TSBITS;
> > +		ts--;
> > +		ts <<= TSBITS;
> > +		ts |= options;
> > +	}
> > +        return ts;
> > +}
> 
> I may be missing something obvious, but I'm failing to see where the
> initial if(options > ts_now) does anything different from the more
> generic logic below it.

You're right, I'll drop the first one.

> Also the 'return ts' line is indented using spaces rather than tabs.

Yes. I'll fix this, thanks.

I think it might be better to avoid duplicating 'cookie_check_timestamp()'
in ipv6/syncookies.c; so i'll change that as well.

I'll wait a few hours before submitting an updated version in case
others wish to provide feedback.

Glenn, should I add your SoB-Line when I send an updated version?
After all, this patch re-uses some of your earlier work.

Thanks again for reviewing this.
