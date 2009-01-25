From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 01/21] [next] qlge: Change to device ID 8000 and
	corresponding flash access.
Date: Sun, 25 Jan 2009 01:45:55 +0000
Message-ID: <1232847955.2808.4.camel@hashbaz.i.decadent.org.uk>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
	 <1232723799-8620-1-git-send-email-ron.mercer@qlogic.com>
	 <1232753339.3005.6.camel@achroite>
	 <20090124192954.GB18522@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:2442 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754239AbZAYBkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2009 20:40:31 -0500
In-Reply-To: <20090124192954.GB18522@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-01-24 at 11:29 -0800, Ron Mercer wrote:
> On Fri, Jan 23, 2009 at 03:28:59PM -0800, Ben Hutchings wrote:
> > On Fri, 2009-01-23 at 07:16 -0800, Ron Mercer wrote:
> > [...]
> > > diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> > > index 16eb9dd..a530f5b 100644
> > > --- a/drivers/net/qlge/qlge_main.c
> > > +++ b/drivers/net/qlge/qlge_main.c
> > [...]
> > > @@ -657,28 +680,38 @@ static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
> > >  	if (status)
> > >  		goto exit;
> > >  	/* get the data */
> > > -	*data = ql_read32(qdev, FLASH_DATA);
> > > +	*data = cpu_to_le32(ql_read32(qdev, FLASH_DATA));
> > [...]
> > 
> > Should be le32_to_cpu not cpu_to_le32.
> > 
> > Ben.
> 
> Ben,
> The flash_param is stored in flash as an array of __le32 elements.  I tried this a number
> of ways and what I came up with is the only combination (I could find)
> that didn't generate compile or sparse warnings and that works on big
> and little endian machines.
> You'll note that I've defined the flash_param using little endian.

But the type of *data is u32, not __le32.

> If I use cpu_to_le32 it would work fine but will produce sparse
> warnings.
> Would it be acceptable if I used a better comment about that I'm doing?

OK, cpu_to_le32() is right but the parameter type should be __le32 *
(and ql_get_flash_params() should be consistent with that).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


