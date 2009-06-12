From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Fri, 12 Jun 2009 10:02:07 +0900
Message-ID: <20090612100207.6f21b208.usui@mxm.nes.nec.co.jp>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	<20090611093149.GA12543@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	tgraf@suug.ch, hadi@cyberus.ca, jarkao2@gmail.com
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:48297 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755373AbZFLBNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 21:13:48 -0400
In-Reply-To: <20090611093149.GA12543@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Thomas

Thank you for your comments.

On Thu, 11 Jun 2009 05:31:49 -0400
Thomas Graf <tgraf@infradead.org> wrote:

> Very nice, this is a big improvement.
> 
> On Thu, Jun 11, 2009 at 06:05:55PM +0900, Minoru Usui wrote:
> > +static int get_tc_classid(u32 *classid, const char *str)
> 
> Maybe make this return u32?

Yes, you are right.
I'll fix it.

> 
> >  {
> > -	return cgrp_cls_state(cgrp)->classid;
> > +	u32 maj, min;
> > +	char *p;
> > +
> > +	/* check "0" for reset request */
> > +	if (!strcmp(str, "0")) {
> > +		*classid = 0;
> > +		return 0;
> > +	}
> > +
> > +	/* parse major number */
> > +	maj = simple_strtoul(str, &p, 16);
> > +	if (p == str) {
> > +		maj = 0;
> > +		if (*p != ':')
> > +			return -EINVAL;
> > +	}
> > +
> > +	/* parse minor number */
> > +	if (*p == ':') {
> > +		if (maj >= (1<<16))
> > +			return -EINVAL;
> > +
> > +		str = p + 1;
> > +		min = simple_strtoul(str, &p, 16);
> > +		if (*p != 0)
> > +			return -EINVAL;
> > +		if (min >= (1<<16))
> > +			return -EINVAL;
> > +	} else if (*p != 0)
> > +		return -EINVAL;
> 
> What do you think about keeping things backwards compatible by
> accepting both the X:Y and XY format?
> 
> } else if (*p != 0)
> 	return strtoul(str, NULL, 0);

OK. I'll do it.
-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
