From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH net-next 2/6] bnx2x: link cleanup
Date: Wed, 20 Jun 2012 15:41:52 -0700
Message-ID: <1340232112.29885.38.camel@joe2Laptop>
References: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
	 <1340182175-916-3-git-send-email-yuvalmin@broadcom.com>
	 <1340204019.29885.9.camel@joe2Laptop>
	 <979A8436335E3744ADCD3A9F2A2B68A5029F62@SJEXCHMB10.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48772 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752189Ab2FTWlw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 18:41:52 -0400
In-Reply-To: <979A8436335E3744ADCD3A9F2A2B68A5029F62@SJEXCHMB10.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 17:50 +0000, Yuval Mintz wrote:
> > >  3. Change msleep(1) --> usleep_range(1000, 1000)
> > 
> > I believe replacing msleep(small) with
> > usleep_range(small * 1000, small * 1000) is
> > not generally a good idea.
> > 
> > Please give usleep_range an actual range to
> > work with and not a repeated single value.
> > 
> > Please think a little more about what a
> > good upper range for the maximum time to
> > sleep should be.
> > 
> > usleep_range(small * 1000, small * 2000)
> > or something similar maybe.
> >
> 
> Sounds good.  I'll change it and re-send the patch series.

Hi Yuval.

Here's a little script from awhile ago that
does it by doubling the small value as the
high value range bound.

http://kerneltrap.org/mailarchive/linux-netdev/2010/12/2/6290711

(replace [path] as appropriate)

$ grep -nPrl --include=*.[ch] "msleep\s*\(\s*1?\d\s*\)" [path] \
  xargs perl -p -i -e 's/msleep\s*\(\s*(1?\d)\s*\)/"usleep_range\(${1}000, " . scalar($1) * 2 . "000\)"/ge'
