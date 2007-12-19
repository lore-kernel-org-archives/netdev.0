From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Wed, 19 Dec 2007 15:30:03 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
References: <20071217134425.GD7409@nuim.ie> <20071218204022.GA8936@nuim.ie>
 <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
 <20071219113125.GF31508@nuim.ie>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1069143135-1198070558=:14629"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58493 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbXLSNaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 08:30:05 -0500
In-Reply-To: <20071219113125.GF31508@nuim.ie>
Content-ID: <Pine.LNX.4.64.0712191522460.14629@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1069143135-1198070558=:14629
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712191522461.14629@kivilampi-30.cs.helsinki.fi>

On Wed, 19 Dec 2007, Gavin McCullagh wrote:

> On Wed, 19 Dec 2007, Ilpo Järvinen wrote:
>
> > Isn't it also much better this way in a case where ACK losses happened,
> > taking the longest RTT in that case is clearly questionable as it
> > may over-estimate considerably.
> 
> Quite so.
> 
> > However, another thing to consider is the possibility of this value being 
> > used in "timeout-like" fashion in ca modules (I haven't read enough ca 
> > modules code to know if any of them does that), on contrary to 
> > determinating just rtt or packet's delay in which case this change seems 
> > appropriate (most modules do the latter). 
> 
> I'm not aware of any, but I haven't read them all either.  I would have
> thought tp->srtt was the value to use in this instance,

Very likely so...

> > Therefore, if timeout-like module exists one should also add
> > TCP_CONG_RTT_STAMP_LONGEST for that particular module and keep using
> > seq_rtt for it like previously and use ca_seq_rtt only for others.
> 
> Seems reasonable.  I'll add this.

...therefore I said "if". I'm not sure what they all do, haven't read them 
all that carefully... :-) Please check first if ..._LONGEST is necessary 
at all by quickly going through how the ca modules use it, I guess most of 
them won't be that complicated, one can probably figure out the intented 
usage by couple of minutes review. If there aren't any modules who need 
delayed ACK & other path caused delays included, ..._LONGEST would just 
end up being unnecessary cruft :-).

> > This part doesn't exists anymore in development tree. Please base this 
> > patch (and anything in future) you intend to get included to mainline
> > onto net-2.6.25 unless there's a very good reason to not do so or 
> > whatever 2.6.xx is the correct net development tree at that time (if
> > one exists). Thanks.
> 
> Will do.   I gather I should use the latest net- tree in future when
> submitting patches.

Doh, I owe you apology as I was probably too hasty to point you towards 
net-2.6.25. I suppose this could by considered as fix as well and 
therefore could probably be accepted to net-2.6 as well, which is for 
bugfixes only after merge window is closed. But it's Dave how will make 
such decisions, not me :-), and it's he who gets to deal with all 
the resulting conflicts ;-) (I added Cc to him).

-- 
 i.
---696243703-1069143135-1198070558=:14629--
