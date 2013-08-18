From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Sun, 18 Aug 2013 16:44:53 -0700
Message-ID: <1376869493.4226.13.camel@edumazet-glaptop>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	 <1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	 <1363651672.21184.17.camel@edumazet-glaptop>
	 <504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
	 <CAPshTCgpE3MoR3D8=EZa_CFVDBwN+fYDZZQrTchhtq-OM_rKzQ@mail.gmail.com>
	 <CAM8tLiNRi7mOb9wwSHuY4867ANUvzd_XxfZLV0gDPO2jKMtWsQ@mail.gmail.com>
	 <1376766116.21329.9.camel@edumazet-glaptop>
	 <CAPshTCh3CqrgasEvFG_Yy8NRHMp_rrQDqn7eRMD9NycmpxaWkQ@mail.gmail.com>
	 <1376840262.21329.40.camel@edumazet-glaptop>
	 <CAPshTCjB9S-Xc4MTs5XXLm6N=0-v_9gxC2SDwCzieTc4Py43fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Kravkov <dkravkov@gmail.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Uday Naik <uday@google.com>,
	Michael Dalton <mwdalton@google.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:45761 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755713Ab3HRXoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 19:44:55 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so4354948pdj.15
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 16:44:55 -0700 (PDT)
In-Reply-To: <CAPshTCjB9S-Xc4MTs5XXLm6N=0-v_9gxC2SDwCzieTc4Py43fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-18 at 14:11 -0700, Jerry Chu wrote:

> It can if the csum validation is deferred. But this requires the stack code to
> aggregate csum from individual pkt header, which can get ugly as one needs
> to remove the header part from the individual csum first.

You can _not_ aggregate packets _before_ validating their checksum, or
else you could end up with a correct final checksum while two or more
segments had buggy checksums. Checksum are already quite weak, please
do not make them even weaker ;)

GRO should not throw out any segments, it is not its role.

If a router receives a bunch of packets, it should forward them
regardless of the (TCP) checksum being good or not.

The final receiver has full responsibility for ultimately validate the
checksums and update various SNMP counters.
