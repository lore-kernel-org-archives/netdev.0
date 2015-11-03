From: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 23:26:27 +0300
Message-ID: <814845359.20151103232627@cogentembedded.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
  <201511021916.18117.marex@denx.de>
  <666821254.20151102231521@cogentembedded.com>
  <201511022125.47892.marex@denx.de>
  <CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
  <56389C38.4080508@pengutronix.de>
  <CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
  <5638CF74.7030001@pengutronix.de>
  <CAAP7ucKWT++AbPPA2kvm965JSjsgCm0OMf0-Vnjwe-ck+xjZZQ@mail.gmail.com>
  <5638EF9C.9070503@hartkopp.net>
Reply-To: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:34522 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584AbbKCU0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 15:26:40 -0500
Received: by lfgh9 with SMTP id h9so30914218lfg.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 12:26:39 -0800 (PST)
In-Reply-To: <5638EF9C.9070503@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Oliver.

> So when thinking about using PF_CAN as ARINC429 base ...

> This is the CAN frame structure:

> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/Documentation/networking/can.txt?h=linux-4.2.y#n264

>     struct can_frame {
>             canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
>             __u8    can_dlc; /* frame payload length in byte (0 .. 8) */
>             __u8    __pad;   /* padding */
>             __u8    __res0;  /* reserved / padding */
>             __u8    __res1;  /* reserved / padding */
>             __u8    data[8] __attribute__((aligned(8)));
>     };


> So what about defining an arinc429_frame like this:

>     struct a429_frame {
>             __u32   label;   /* ARINC 429 label */
>             __u8    length;  /* always set to 3 */
>             __u8    __pad;   /* padding */
>             __u8    __res0;  /* reserved / padding */
>             __u8    __res1;  /* reserved / padding */
>             __u8    data[8] __attribute__((aligned(8)));
>     };
What  would  be  the  benefit  besides  reusing  CAN tools to have
arinc429 frame structure four times larger that it needs to be?

It just adds complexity to implement translation in device driver from
can-like  structures  to  native  4-bytes message. Similar translation
will be needed in application as well.

There   is   no   real   processing  needed for ARINC429 frames inside
framework. Almost all features  are  done  by  HW  itself  (label  filters,
label  priority matching,   label   bit  flipping,  rate  selection,  parity
and  sdi decoding) or by application.

I'd  prefer to have ARINC framework simple as it could be and separate
from  CAN,  as  these  buses are not similar, besides desire to re-use
SocketCAN interface/API to expose ARINC429 bus.

--
Best regards,
Andrey Vostrikov
