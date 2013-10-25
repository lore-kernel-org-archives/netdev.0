From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v5] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Fri, 25 Oct 2013 11:31:58 -0700
Message-ID: <1382725918.2425.2.camel@joe-AO722>
References: <5267F4BD.70409@xdin.com> <1382547142.22433.18.camel@joe-AO722>
	 <526AB665.5020402@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	=?ISO-8859-1?Q?El=EDas?= Molina =?ISO-8859-1?Q?Mu=F1oz?=
	<elias.molina@ehu.es>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0191.hostedemail.com ([216.40.44.191]:54844 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753349Ab3JYScB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 14:32:01 -0400
In-Reply-To: <526AB665.5020402@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 20:20 +0200, Arvid Brodin wrote:
> On 2013-10-23 18:52, Joe Perches wrote:
> > On Wed, 2013-10-23 at 18:09 +0200, Arvid Brodin wrote:
[]
> >> +/* above(a, b) - return 1 if a > b, 0 otherwise.
> >> + */
> >> +static bool above(u16 a, u16 b)
> >> +{
> >> +	/* Remove inconsistency where above(a, b) == below(a, b) */
> >> +	if ((int) b - a == 32768)
> >> +		return 0;
> >> +
> >> +	return (((s16) (b - a)) < 0);
> >> +}
> >> +#define below(a, b)		above((b), (a))
> >> +#define above_or_eq(a, b)	(!below((a), (b)))
> >> +#define below_or_eq(a, b)	(!above((a), (b)))
> > 
> > This looks odd. 
> 
> It relies on unsigned arithmetic to compare two values that may wrap. I.e.,
> it doesn't care about the absolute sizes, but only about the distance 
> between the numbers. 
> 
> It is inspired in part by the code in jiffies.h, but adapted to 16-bit
> types. The code you suggested (below) will not work in this case.
> 
> See e.g. http://en.wikipedia.org/wiki/Serial_number_arithmetic

No worries, I was just reading the comment as the
comment doesn't match the code.

Perhaps the comment should be updated to reflect the
wrapping test.
