From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 01/21] [next] qlge: Change to device ID 8000 and
	corresponding flash access.
Date: Sat, 24 Jan 2009 11:29:54 -0800
Message-ID: <20090124192954.GB18522@linux-ox1b.qlogic.org>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org> <1232723799-8620-1-git-send-email-ron.mercer@qlogic.com> <1232753339.3005.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:6096 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbZAXTbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2009 14:31:06 -0500
Content-Disposition: inline
In-Reply-To: <1232753339.3005.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2009 at 03:28:59PM -0800, Ben Hutchings wrote:
> On Fri, 2009-01-23 at 07:16 -0800, Ron Mercer wrote:
> [...]
> > diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> > index 16eb9dd..a530f5b 100644
> > --- a/drivers/net/qlge/qlge_main.c
> > +++ b/drivers/net/qlge/qlge_main.c
> [...]
> > @@ -657,28 +680,38 @@ static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
> >  	if (status)
> >  		goto exit;
> >  	/* get the data */
> > -	*data = ql_read32(qdev, FLASH_DATA);
> > +	*data = cpu_to_le32(ql_read32(qdev, FLASH_DATA));
> [...]
> 
> Should be le32_to_cpu not cpu_to_le32.
> 
> Ben.

Ben,
The flash_param is stored in flash as an array of __le32 elements.  I tried this a number
of ways and what I came up with is the only combination (I could find)
that didn't generate compile or sparse warnings and that works on big
and little endian machines.
You'll note that I've defined the flash_param using little endian.
If I use cpu_to_le32 it would work fine but will produce sparse
warnings.
Would it be acceptable if I used a better comment about that I'm doing?

Ron
