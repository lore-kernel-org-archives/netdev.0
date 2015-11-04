From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 14:54:16 +0100
Message-ID: <201511041454.16413.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <201511032243.03029.marex@denx.de> <CAAP7ucJbWFZ-DCH1dhvJUYcYosTfYgsHx9Mdnwq+K166yjYJaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:41330 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965184AbbKDOCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 09:02:39 -0500
In-Reply-To: <CAAP7ucJbWFZ-DCH1dhvJUYcYosTfYgsHx9Mdnwq+K166yjYJaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 04, 2015 at 10:34:50 AM, Aleksander Morgado wrote:
> On Tue, Nov 3, 2015 at 10:43 PM, Marek Vasut <marex@denx.de> wrote:
> > On Tuesday, November 03, 2015 at 08:28:43 PM, Oliver Hartkopp wrote:
> >> On 11/03/2015 08:19 PM, Marek Vasut wrote:
> >> > On Tuesday, November 03, 2015 at 07:03:26 PM, Oliver Hartkopp wrote:
> >> >> On 11/03/2015 06:41 PM, Marek Vasut wrote:
> >> >>> On Tuesday, November 03, 2015 at 06:32:12 PM, Oliver Hartkopp wrote:
> >> >>> 
> >> >>> [...]
> >> >>> 
> >> >>>> It looks like you need to shift the stuff in user space every time.
> >> >>>> 
> >> >>>> So you might better think of something like this:
> >> >>>>     struct a429_frame {
> >> >>>>     
> >> >>>>             __u32   label;   /* ARINC 429 label */
> >> >>>>             __u8    length;  /* always set to 8 */
> >> >>>>             __u8    __pad;   /* padding */
> >> >>>>             __u8    __res0;  /* reserved / padding */
> >> >>>>             __u8    __res1;  /* reserved / padding */
> >> >>>>             __u32   data __attribute__((aligned(8)));
> >> >>>>             __u8    p;       /* p */
> >> >>>>             __u8    ssm;     /* ssm */
> >> >>>>             __u8    sdi;     /* sdi */
> >> >>>>             __u8    __end;   /* padding */
> >> >>>>     
> >> >>>>     };
> >> >>> 
> >> >>> You don't want to interpret those P(arity)/SSM/SDI bits, since they
> >> >>> differ depending on whatever the remote party sends. That's why I
> >> >>> decided to just make those into 3-bytes of data and let the userland
> >> >>> application deal with it as seen fit. Besides, the ARINC "FTP"
> >> >>> really uses those 3 bytes as plain data.
> >> >> 
> >> >> Ok. I did not know what P was for :-)
> >> > 
> >> > Oh yeah. P is parity and it's optional as well and can be odd/even
> >> > depending on the remote endpoint (sigh).
> >> > 
> >> >> Btw. it can make sense to introduce an union struct where different
> >> >> options to access the content are possible.
> >> > 
> >> > This would be pretty nasty I think. By reading the ARINC
> >> > specification, the SSM can be either 2 or 3 bits, the SDI is
> >> > who-knows-what depending on the remote endpoint and the P is also not
> >> > always present. I'm not convinced that the kernel should interpret
> >> > the 3 byte ARINC payload in any way. (but I wonder if my argument
> >> > presented above is convincing at all either ...).
> >> 
> >> Right.
> >> 
> >> When we define a user visible data structure, this is written into
> >> stone.
> >> 
> >> When ARINC isn't even sure about the detailed interpretation we should
> >> definitely keep our fingers away from doing it ourselves.
> > 
> > Right. Besides, such extension to the ABI can be done later if the need
> > arises (which I seriously doubt), can't it ? Handling the payload as a
> > CAN payload makes sense.
> 
> Agree on this, the three non-label bytes in an ARINC word should be
> taken as opaque payload. The only exception would be the parity most
> significant bit, but I don't think it'd be an issue to have that in
> the opaque payload.

About the parity -- can we add some flag into the datagram to indicate we
want hardware to calculate the parity for that particular datagram for us?
And we'd also need to indicate what type of parity. I dunno if this is worth
the hassle.

Best regards,
Marek Vasut
