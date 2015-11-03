From: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 00:52:22 +0300
Message-ID: <1197214174.20151104005222@cogentembedded.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>   
  <201511021916.18117.marex@denx.de>
  <666821254.20151102231521@cogentembedded.com>
  <201511022125.47892.marex@denx.de>
  <CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>
  <56389C38.4080508@pengutronix.de>
  <CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
  <5638CF74.7030001@pengutronix.de>
  <CAAP7ucKWT++AbPPA2kvm965JSjsgCm0OMf0-Vnjwe-ck+xjZZQ@mail.gmail.com>
  <5638EF9C.9070503@hartkopp.net> <814845359.20151103232627@cogentembedded.com>
  <56392607.5060200@hartkopp.net>
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
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34378 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871AbbKCVwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:52:36 -0500
Received: by lfgh9 with SMTP id h9so31860731lfg.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 13:52:34 -0800 (PST)
In-Reply-To: <56392607.5060200@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Oliver.

> Comparing to typical ethernet frames with 1500 bytes the 16 bytes for CAN
> frames or 72 bytes for CAN FD frames are already too small in relation to the
> socket buffer overhead.
Ok,  if there is no big difference using 4-bytes structure or 16-bytes
structures, I do not have any objections.

> If you want to improve the memory efficiency for arinc290 you should probably
> consider to implement a character device based driver instead of creating a
> new network protocol family.
I  suppose  such  drivers  have  been  implemented before, but by some
reasons  socket  API is preferred now. I do not have any details regarding
this.

>> It just adds complexity to implement translation in device driver from
>> can-like  structures  to  native  4-bytes message. Similar translation
>> will be needed in application as well.

> That's BS. You put the data into a struct a429_frame at driver level and you
> read the data from struct a429_frame on application level.

> Where is the 'translation'?
Ok,  I overreacted a bit. Even in current proposal it is needed to move
bytes in HI-3593 driver as  well, as this chip accepts label as last byte,
instead  of  first  one  in SPI transfers. It was just a wish to use
same data without any actions when moving it between framework and HW.

> From what I've read so far there's also the sending of cyclic messages and
> label filtering outside the HW - or why did you copy/paste the can_id/label
> filter mechanism from af_can.c ?
It  is  not  I  who  copied CAN code, and I do not think that CAN label filter
mechanism  fits ARINC, as it looks overcomplicated for small label space
in ARINC429

-- 
Best regards,
Andrey Vostrikov
