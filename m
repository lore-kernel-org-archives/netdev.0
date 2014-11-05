From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/1] ip-link: in human readable output use dynamic
 precision length
Date: Wed, 5 Nov 2014 09:30:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9E9068@AcuExch.aculab.com>
References: <20141104114421.6a7f9de5@leda.localdomain>
	<1415098208-17942-1-git-send-email-mail@eworm.de>
	<063D6719AE5E284EB5DD2968C1650D6D1C9E72A7@AcuExch.aculab.com>
 <20141104221038.440fd9d7@leda.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Christian Hesse' <mail@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60981 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751325AbaKEJcv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 04:32:51 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28532-03 for <netdev@vger.kernel.org>;
 Wed,  5 Nov 2014 09:32:42 +0000 (GMT)
In-Reply-To: <20141104221038.440fd9d7@leda.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Hesse
...
> 
> I do not like this at all... snprintf() would be nice for a catch-all, but we
> have to take care of negative values. So let's try something different.
> I will think about it and send a new patch.
> 
> > > +		precision = 0;
> > > +
> > > +	snprintf(buf, sizeof(buf), "%.*f%c%s", precision,
> > > +		(double) count / powi, *prefix, use_iec ? "i" : "");
> > >
> > >  	fprintf(fp, "%-*s ", width, buf);
> > >  }
> >
> > The above will go wrong in all sorts of horrid ways....
> > For instance you are doing a truncating integer divide, but the FP
> > value will get rounded for display.
> >
> > It would be safer to use integers throughout.
> 
> My implementation used integers, but Stephen changes this to floating point
> with his cleanups.
> 
> IMHO the rounding is ok. This is for *human* readability. ;)
> Whoever wants correct values should not ask ip to print human readable values
> but rely on pure numbers.

Rounding the value is fine, the difference between 1000 and 1024
is not that great either.
The problem is that the two calculations get rounded differently.
If the FP value ends up being 9.999999 it will be printed as 10.0
but your field width calculation will only have allowed for
a single digit.

> > Oh, and a 2Mbit E1 link is actually 2048000 :-)
> 
> Sorry? Did not get the point.
That was really in reference to a much earlier comment about comms
always using 1000.

	David
