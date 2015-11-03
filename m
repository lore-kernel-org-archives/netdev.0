From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 18:41:09 +0100
Message-ID: <201511031841.09549.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <CAAP7ucKWT++AbPPA2kvm965JSjsgCm0OMf0-Vnjwe-ck+xjZZQ@mail.gmail.com> <5638EF9C.9070503@hartkopp.net>
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
Received: from mail-out.m-online.net ([212.18.0.9]:32827 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004AbbKCRlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 12:41:10 -0500
In-Reply-To: <5638EF9C.9070503@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, November 03, 2015 at 06:32:12 PM, Oliver Hartkopp wrote:

[...]

> It looks like you need to shift the stuff in user space every time.
> 
> So you might better think of something like this:
> 
>     struct a429_frame {
>             __u32   label;   /* ARINC 429 label */
>             __u8    length;  /* always set to 8 */
>             __u8    __pad;   /* padding */
>             __u8    __res0;  /* reserved / padding */
>             __u8    __res1;  /* reserved / padding */
>             __u32   data __attribute__((aligned(8)));
>             __u8    p;       /* p */
>             __u8    ssm;     /* ssm */
>             __u8    sdi;     /* sdi */
>             __u8    __end;   /* padding */
>     };

You don't want to interpret those P(arity)/SSM/SDI bits, since they differ
depending on whatever the remote party sends. That's why I decided to just
make those into 3-bytes of data and let the userland application deal with
it as seen fit. Besides, the ARINC "FTP" really uses those 3 bytes as plain
data.

> Good thing would be that you can directly see the content in logfiles and
> you can easily modify the content on the fly by can-gw.
> 
> Of course the arinc netdevice driver would have to take care to do the
> correct rx/tx whatever. But routing and processing arinc content through
> the CAN stack does not seem to be a bad idea IMO.

Pretty much, yeah.

Best regards,
Marek Vasut
