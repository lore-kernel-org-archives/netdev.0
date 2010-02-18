From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next PATCH v4 2/3] net: TCP thin linear timeouts
Date: Thu, 18 Feb 2010 11:09:51 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002181102260.9961@melkinpaasi.cs.helsinki.fi>
References: <4B7AAE69.8020701@simula.no> <20100217.163255.133898079.davem@davemloft.net> <alpine.DEB.2.00.1002181040520.9961@melkinpaasi.cs.helsinki.fi> <4B7CFDE4.4010003@simula.no> <4B7D01CE.1030101@lastsummer.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-1275017534-1266484191=:9961"
Cc: Andreas Petlund <apetlund@simula.no>,
	Netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com,
	hannemann@nets.rwth-aachen.de, LKML <linux-kernel@vger.kernel.org>,
	shemminger@vyatta.com, william.allen.simpson@gmail.com,
	damian@tvk.rwth-aachen.de, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44589 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab0BRJJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 04:09:53 -0500
In-Reply-To: <4B7D01CE.1030101@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1275017534-1266484191=:9961
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 18 Feb 2010, Franco Fichtner wrote:

> Andreas Petlund wrote:
> > On 02/18/2010 09:41 AM, Ilpo Järvinen wrote:
> >   
> > > On Wed, 17 Feb 2010, David Miller wrote:
> > > 
> > >     
> > > > From: Andreas Petlund <apetlund@simula.no>
> > > > Date: Tue, 16 Feb 2010 15:40:41 +0100
> > > > 
> > > >       
> > > > > @@ -341,6 +342,8 @@ struct tcp_sock {
> > > > >  	u16	advmss;		/* Advertised MSS
> > > > > */
> > > > >  	u8	frto_counter;	/* Number of new acks after RTO */
> > > > >  	u8	nonagle;	/* Disable Nagle algorithm?
> > > > > */
> > > > > +	u8      thin_lto    : 1,/* Use linear timeouts for thin
> > > > > streams */
> > > > > +		thin_undef  : 7;
> > > > >          
> > > > There is now a gap of 3 unused bytes here in this critical
> > > > core TCP socket data structure.
> > > > 
> > > > Please either find a way to avoid this hole, or document
> > > > it with a comment.
> > > >       
> > > There would be multiple bits free for use in both frto_counter and nonagle
> > > byte.
> > > 
> > >     
> > 
> > I was playing aroud with this setup:
> > 
> > =========
> > u8	nonagle     : 4,/* Disable Nagle algorithm?             */
> > 	thin_lto    : 1,/* Use linear timeouts for thin streams */
> > 	thin_dupack : 1,/* Fast retransmit on first dupack      */
> > 	thin_undef  : 2;
> > =========
> > 
> > Do you think that would do the trick?
> >   
> 
> According to Ilpo, it would be ok to reduce both ftro_counter and
> nonagle, so why not join all these into u16 and leave the remaining
> free bits documented for other people. Like this:
> 
>    u16 frto_counter:x; /* Number of new acks after RTO */
>    u16 nonagle:y; /* Disable Nagle algorithm? */
>    u16 thin_lto:1; /* Use linear timeouts for thin streams */
>    u16 unused:15-x-y;
> 
> Not sure about the y and x. Ilpo, can you comment on those values?

I don't remember top of the hat how much of nonagle used, but for 
frto_counter max value was 3 iirc. However, I'm unsure if compiler is 
nowadays wise enough to handle bitfields in some not all so stupid way. 
Btw, also in ecn_flags we have some empty space. But all in all that 
didn't vacate enough to get 4 bytes so I haven't taken effort of 
combining.

-- 
 i.
---696230645-1275017534-1266484191=:9961--
