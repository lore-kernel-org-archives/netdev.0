From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v3 6/6] misc/ifstat: simplify unsigned value
 comparison
Date: Fri, 24 Jun 2016 13:55:08 +0200
Message-ID: <20160624115508.GC28345@orbyte.nwl.cc>
References: <1466703254-5174-1-git-send-email-phil@nwl.cc>
 <1466703254-5174-7-git-send-email-phil@nwl.cc>
 <063D6719AE5E284EB5DD2968C1650D6D5F4E3EA0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44466 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbcFXLy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 07:54:28 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4E3EA0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 09:20:32AM +0000, David Laight wrote:
> From: Phil Sutter
> > Sent: 23 June 2016 18:34
> > 
> > By directly comparing the value of both unsigned variables, casting to
> > signed becomes unnecessary.
> > 
> > This also fixes for compiling with older versions of gcc (at least
> > <=3.4.6) which emit the following warning:
> > 
> > | ifstat.c: In function `update_db':
> > | ifstat.c:542: warning: comparison is always false due to limited range of data type
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  misc/ifstat.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/misc/ifstat.c b/misc/ifstat.c
> > index abbb4e732fcef..9a44da487599e 100644
> > --- a/misc/ifstat.c
> > +++ b/misc/ifstat.c
> > @@ -539,7 +539,7 @@ static void update_db(int interval)
> >  				int i;
> > 
> >  				for (i = 0; i < MAXS; i++) {
> > -					if ((long)(h1->ival[i] - n->ival[i]) < 0) {
> > +					if (h1->ival[i] < n->ival[i]) {
> >  						memset(n->ival, 0, sizeof(n->ival));
> >  						break;
> 
> That isn't the same check.
> The original code is using modulo arithmetic.

Oh, right! The code behaves differently if h1->ival[i] is close to
ULONG_MAX and n->ival[i] is very small. Though I don't see where this
becomes relevant. Am I missing another scenario?

Thanks, Phil
