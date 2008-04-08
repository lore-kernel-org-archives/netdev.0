From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: why are there messages like assertion ((int)tcp_packets_in_flight(tp)...
Date: Tue, 8 Apr 2008 12:17:07 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804081213200.32028@wrl-59.cs.helsinki.fi>
References: <18406.49168.311576.570515@fisica.ufpr.br>
 <Pine.LNX.4.64.0803261353100.24534@kivilampi-30.cs.helsinki.fi>
 <18410.25779.32254.261486@fisica.ufpr.br> <Pine.LNX.4.64.0803262246460.14579@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696243703-797132128-1206564814=:14579"
Cc: Netdev <netdev@vger.kernel.org>
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52044 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbYDHJRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 05:17:10 -0400
In-Reply-To: <Pine.LNX.4.64.0803262246460.14579@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0804081213201.32028@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-797132128-1206564814=:14579
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803262318381.11089@svm-3.cs.Helsinki.FI>

On Wed, 26 Mar 2008, Ilpo Järvinen wrote:

> On Wed, 26 Mar 2008, Carlos Carvalho wrote:
> 
> > Ilpo Järvinen (ilpo.jarvinen@helsinki.fi) wrote on 26 March 2008 14:57:
> >  >On Sun, 23 Mar 2008, Carlos Carvalho wrote:
> >  >
> >  >> We get these messages in the log from time to time:
> >  >> 
> >  >> assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at net/ipv4/tcp_input.c (1274)
> >  >> 
> >  >> What do they mean? Is there a way to get rid of them?
> >  >
> >  >> They usually appear at high net traffic periods.
> >  >
> >  >Your mail is lacking key bit of information:
> >  >- What kernel version you're using?
> > 
> > 2.6.22.18.
> >  >- Is this only message?
> > 
> > Yes.
> > 
> >  >Especially I'm interested in if Leak printouts show up, but more
> >  >complete snippet of the log wouldn't hurt (I don't need all those
> >  >boot up details though :-)).
> > 
> > I don't know what you mean by leak but there aren't any other
> > messages.
> 
> Since there aren't any other messages, it very likely equals to the case 
> I already debugged enough to analyze its effect...
>
> >  >It may mean a number of things. Basically packet counting is not that 
> >  >accurate as it should, whether that's causing bad things or not, it 
> >  >depends...
> >  >
> >  >...In case it's something before 2.6.24, there's one potential patch 
> >  >available in archives adding one clearly missing left_out adjustment. 
> > 
> > Could you point it to me? I cannot upgrade now because I also use the
> > vserver patch. I cannot test without it because this message only
> > appears when net traffic is high enough, and this is our only machine
> > in this condition.
> 
> http://marc.info/?l=linux-netdev&m=119910263911111&w=2
> 
> ...I think it should apply cleanly to 2.6.22 as well.

Another place that could cause it is the recently discovered flaw with 
newreno in tcp_simple_retransmit. A patch (which won't work with 2.6.22 
though) and a bit description of it:

  http://marc.info/?l=linux-netdev&m=120756760521961&w=2


-- 
 i.
---696243703-797132128-1206564814=:14579--
