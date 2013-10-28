From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5] net/hsr: Add support for the High-availability Seamless Redundancy protocol (HSRv0)
Date: Mon, 28 Oct 2013 09:17:06 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73B9@saturn3.aculab.com>
References: <5267F4BD.70409@xdin.com> <1382547142.22433.18.camel@joe-AO722> <526AB665.5020402@xdin.com> <1382725918.2425.2.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "David Miller" <davem@davemloft.net>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Javier Boticario" <jboticario@gmail.com>,
	<balferreira@googlemail.com>,
	=?Windows-1252?Q?El=EDas_Molina_Mu=F1oz?= <elias.molina@ehu.es>
To: "Joe Perches" <joe@perches.com>,
	"Arvid Brodin" <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40924 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755683Ab3J1JTJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 05:19:09 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08299-03 for <netdev@vger.kernel.org>;
 Mon, 28 Oct 2013 09:19:06 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1382725918.2425.2.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: Re: [PATCH v5] net/hsr: Add support for the High-availability Seamless Redundancy protocol
> (HSRv0)
> 
> On Fri, 2013-10-25 at 20:20 +0200, Arvid Brodin wrote:
> > On 2013-10-23 18:52, Joe Perches wrote:
> > > On Wed, 2013-10-23 at 18:09 +0200, Arvid Brodin wrote:
> []
> > >> +/* above(a, b) - return 1 if a > b, 0 otherwise.
> > >> + */
> > >> +static bool above(u16 a, u16 b)
> > >> +{
> > >> +	/* Remove inconsistency where above(a, b) == below(a, b) */
> > >> +	if ((int) b - a == 32768)
> > >> +		return 0;
> > >> +
> > >> +	return (((s16) (b - a)) < 0);
> > >> +}
> > >> +#define below(a, b)		above((b), (a))
> > >> +#define above_or_eq(a, b)	(!below((a), (b)))
> > >> +#define below_or_eq(a, b)	(!above((a), (b)))
> > >
> > > This looks odd.
> >
> > It relies on unsigned arithmetic to compare two values that may wrap. I.e.,
> > it doesn't care about the absolute sizes, but only about the distance
> > between the numbers.

I'd have thought it wasn't really worth worrying about what happens
when a ^ b == 0x8000. Anything using modulo 16 distances shouldn't
really see such values.
Perhaps just document the effect.

Also, if these definitions are in a .h file they need better names

	David
