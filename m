From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Sun, 18 Aug 2013 08:37:42 -0700
Message-ID: <1376840262.21329.40.camel@edumazet-glaptop>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	 <1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	 <1363651672.21184.17.camel@edumazet-glaptop>
	 <504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
	 <CAPshTCgpE3MoR3D8=EZa_CFVDBwN+fYDZZQrTchhtq-OM_rKzQ@mail.gmail.com>
	 <CAM8tLiNRi7mOb9wwSHuY4867ANUvzd_XxfZLV0gDPO2jKMtWsQ@mail.gmail.com>
	 <1376766116.21329.9.camel@edumazet-glaptop>
	 <CAPshTCh3CqrgasEvFG_Yy8NRHMp_rrQDqn7eRMD9NycmpxaWkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Kravkov <dkravkov@gmail.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:43516 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3HRPhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 11:37:45 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so3977134pbb.13
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 08:37:44 -0700 (PDT)
In-Reply-To: <CAPshTCh3CqrgasEvFG_Yy8NRHMp_rrQDqn7eRMD9NycmpxaWkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-18 at 04:55 -0700, Jerry Chu wrote:
> On Sat, Aug 17, 2013 at 12:01 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sat, 2013-08-17 at 21:52 +0300, Dmitry Kravkov wrote:
> >
> >>
> >> Current bnx2x HW is not able to perform CSUM validation for
> >> encapsulated packets, so in any case host needs to do that.
> >> Today GRO/TPA feature depends on CSUM, but theoretically (i did not
> >> investigate it) and probably HW can provide aggregated packets w/o
> >> csum validation - this will save headers processing for host.
> >
> > I am not sure I understand this.
> >
> > Aggregation cannot be done if csums are not validated.
> 
> Unless all the csums from aggregated pkts are also aggregated into one
> (so that the host computes s/w csum on the large pkt and validates against
> the aggregated csum...) There may be some performance benefit for doing
> this but it may arguably weaken already weak 1's complement csum.

To aggregate two packets, you first have to make sure the checksums of
each packet are ok. If the hardware does not validate checksum, then it
cannot aggregate packets.

Sure, CHECKSUM_COMPLETE support would be nice, so that linux can perform
aggregation without having to bring into cpu cache the whole frame.
