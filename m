From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 20:19:29 +0100
Message-ID: <201511032019.29236.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <201511031841.09549.marex@denx.de> <5638F6EE.10505@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:55651 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755874AbbKCTTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 14:19:40 -0500
In-Reply-To: <5638F6EE.10505@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, November 03, 2015 at 07:03:26 PM, Oliver Hartkopp wrote:
> On 11/03/2015 06:41 PM, Marek Vasut wrote:
> > On Tuesday, November 03, 2015 at 06:32:12 PM, Oliver Hartkopp wrote:
> > 
> > [...]
> > 
> >> It looks like you need to shift the stuff in user space every time.
> >> 
> >> So you might better think of something like this:
> >>     struct a429_frame {
> >>     
> >>             __u32   label;   /* ARINC 429 label */
> >>             __u8    length;  /* always set to 8 */
> >>             __u8    __pad;   /* padding */
> >>             __u8    __res0;  /* reserved / padding */
> >>             __u8    __res1;  /* reserved / padding */
> >>             __u32   data __attribute__((aligned(8)));
> >>             __u8    p;       /* p */
> >>             __u8    ssm;     /* ssm */
> >>             __u8    sdi;     /* sdi */
> >>             __u8    __end;   /* padding */
> >>     
> >>     };
> > 
> > You don't want to interpret those P(arity)/SSM/SDI bits, since they
> > differ depending on whatever the remote party sends. That's why I
> > decided to just make those into 3-bytes of data and let the userland
> > application deal with it as seen fit. Besides, the ARINC "FTP" really
> > uses those 3 bytes as plain data.
> 
> Ok. I did not know what P was for :-)

Oh yeah. P is parity and it's optional as well and can be odd/even depending
on the remote endpoint (sigh).

> Btw. it can make sense to introduce an union struct where different options
> to access the content are possible.

This would be pretty nasty I think. By reading the ARINC specification, the
SSM can be either 2 or 3 bits, the SDI is who-knows-what depending on the
remote endpoint and the P is also not always present. I'm not convinced that
the kernel should interpret the 3 byte ARINC payload in any way. (but I wonder
if my argument presented above is convincing at all either ...).

So while we can do it for the common case, I wonder if this isn't 
overengineering things a bit right from the beginning. Wouldn't it
make more sense to add this only once the need for it is there?
Such change won't create an incompatible change to the ABI, so from
my perspective, postponing it won't hurt.

> E.g. you might have a 32 bit word, some bit-wise specification and a four
> byte tuple to access the three bytes for ARINC FTP ...

I understand the idea, yes.

Best regards,
Marek Vasut
