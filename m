From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next PATCH v4 2/3] net: TCP thin linear timeouts
Date: Thu, 18 Feb 2010 11:24:38 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002181120240.9961@melkinpaasi.cs.helsinki.fi>
References: <4B7AAE69.8020701@simula.no> <20100217.163255.133898079.davem@davemloft.net> <alpine.DEB.2.00.1002181040520.9961@melkinpaasi.cs.helsinki.fi> <4B7CFDE4.4010003@simula.no> <4B7D01CE.1030101@lastsummer.de> <alpine.DEB.2.00.1002181102260.9961@melkinpaasi.cs.helsinki.fi>
 <4B7D05ED.4060900@simula.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-638774431-1266484965=:9961"
Cc: Franco Fichtner <franco@lastsummer.de>,
	Netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com,
	hannemann@nets.rwth-aachen.de, LKML <linux-kernel@vger.kernel.org>,
	shemminger@vyatta.com, william.allen.simpson@gmail.com,
	damian@tvk.rwth-aachen.de, ebiederm@xmission.com,
	David Miller <davem@davemloft.net>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B7D05ED.4060900@simula.no>
Content-ID: <alpine.DEB.2.00.1002181123020.9961@melkinpaasi.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-638774431-1266484965=:9961
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1002181123021.9961@melkinpaasi.cs.helsinki.fi>

On Thu, 18 Feb 2010, Andreas Petlund wrote:

> On 02/18/2010 10:09 AM, Ilpo Järvinen wrote:
> > On Thu, 18 Feb 2010, Franco Fichtner wrote:
> > 
> >> Andreas Petlund wrote:
> >>> On 02/18/2010 09:41 AM, Ilpo Järvinen wrote:
> >>>   
> >>>> On Wed, 17 Feb 2010, David Miller wrote:
> >>>>
> >>>>     
> >>>>> From: Andreas Petlund <apetlund@simula.no>
> >>>>> Date: Tue, 16 Feb 2010 15:40:41 +0100
> >>>>>
> >>>>>       
> >>>>>> @@ -341,6 +342,8 @@ struct tcp_sock {
> >>>>>>  	u16	advmss;		/* Advertised MSS
> >>>>>> */
> >>>>>>  	u8	frto_counter;	/* Number of new acks after RTO */
> >>>>>>  	u8	nonagle;	/* Disable Nagle algorithm?
> >>>>>> */
> >>>>>> +	u8      thin_lto    : 1,/* Use linear timeouts for thin
> >>>>>> streams */
> >>>>>> +		thin_undef  : 7;
> >>>>>>          
> >>>>> There is now a gap of 3 unused bytes here in this critical
> >>>>> core TCP socket data structure.
> >>>>>
> >>>>> Please either find a way to avoid this hole, or document
> >>>>> it with a comment.
> >>>>>       
> >>>> There would be multiple bits free for use in both frto_counter and nonagle
> >>>> byte.
> >>>>
> >>>>     
> >>>
> >>> I was playing aroud with this setup:
> >>>
> >>> =========
> >>> u8	nonagle     : 4,/* Disable Nagle algorithm?             */
> >>> 	thin_lto    : 1,/* Use linear timeouts for thin streams */
> >>> 	thin_dupack : 1,/* Fast retransmit on first dupack      */
> >>> 	thin_undef  : 2;
> >>> =========
> >>>
> >>> Do you think that would do the trick?
> >>>   
> >>
> >> According to Ilpo, it would be ok to reduce both ftro_counter and
> >> nonagle, so why not join all these into u16 and leave the remaining
> >> free bits documented for other people. Like this:
> >>
> >>    u16 frto_counter:x; /* Number of new acks after RTO */
> >>    u16 nonagle:y; /* Disable Nagle algorithm? */
> >>    u16 thin_lto:1; /* Use linear timeouts for thin streams */
> >>    u16 unused:15-x-y;
> >>
> >> Not sure about the y and x. Ilpo, can you comment on those values?
> > 
> > I don't remember top of the hat how much of nonagle used, but for 
> > frto_counter max value was 3 iirc. 
> 
> I think nonagle uses 4 bits:
> ======
> #define TCP_NAGLE_OFF           1       /* Nagle's algo is disabled */
> #define TCP_NAGLE_CORK          2       /* Socket is corked         */
> #define TCP_NAGLE_PUSH          4       /* Cork is overridden for already queued data */
> ======
> 
> > However, I'm unsure if compiler is 
> > nowadays wise enough to handle bitfields in some not all so stupid way.
> 
> Would you then recommend to use a byte for each value, thus avoiding the 
> bitfields? 

I don't know about the current compilers but at least in past there has 
been a bias against bitfields. Alternative would be to combine and code 
the accessors manually (thus bypassing any "too clever" compiler 
intelligence).

-- 
 i.
---696230645-638774431-1266484965=:9961--
