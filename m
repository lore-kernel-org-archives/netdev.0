From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/9] [TCP]: Remove unnecessary local variables
Date: Mon, 31 Dec 2007 16:17:58 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712311559170.4163@kivilampi-30.cs.helsinki.fi>
References: <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071231.044759.141743569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-2034540995-1199110678=:4163"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50066 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbXLaOR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 09:17:59 -0500
In-Reply-To: <20071231.044759.141743569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2034540995-1199110678=:4163
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 31 Dec 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 31 Dec 2007 12:47:51 +0200
> 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
>  ...
> >  
> > -	in_flight = tcp_packets_in_flight(tp);
> > -	cwnd = tp->snd_cwnd;
> > -	if (in_flight < cwnd)
> > -		return (cwnd - in_flight);
> > +	if (tcp_packets_in_flight(tp) < tp->snd_cwnd)
> > +		return tp->snd_cwnd - tcp_packets_in_flight(tp);
> >  
> 
> I don't know about this one.
> 
> Although tcp_packets_in_flight() is inline and the compiler
> should CSE the first call into a local register and not
> redo the calculation:
> 
> 1) That isn't something to rely upon.  The compiler might look
>    at a function or set of functions in this file and decide
>    to not inline tcp_packets_in_flight() or not see the CSE
>    opportunity and that the second call is redundant.

How about doing something really straight-forward then:

  return max_t(s32, tp->snd_cwnd - tcp_packets_in_flight(tp), 0);

...I was a bit unsure to add such type trickery and thus didn't go
for that right away.

> So best to keep the local vars here.
> 
> I also think the code is clearer that way too.

Fair enough.


-- 
 i.
---696243703-2034540995-1199110678=:4163--
