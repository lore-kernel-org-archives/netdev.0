From: Yannick Koehler <yannick@koehler.name>
Subject: Re: Unix Socket buffer attribution
Date: Wed, 23 Jan 2013 11:36:49 -0500
Message-ID: <CAJ4BwwG-fimMeSD_DSNZZz=Vjz3Qk_58qEnMGv_gmn0rTSeZAg@mail.gmail.com>
References: <CAJ4BwwFZo=ktoNBpw14yxyvR1QPQ_xVzKRs=R7qv03g1uwn8pg@mail.gmail.com>
	<kdoibl$978$1@ger.gmane.org>
	<1358951180.12374.787.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:58319 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381Ab3AWQgu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 11:36:50 -0500
Received: by mail-wi0-f182.google.com with SMTP id hn14so902878wib.3
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 08:36:49 -0800 (PST)
In-Reply-To: <1358951180.12374.787.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So what prevents a malicious program to DOS the machine ?

The recv queue (checked with recvq_full()) and receiving's socket
rcvbuf (check added in my patch).

Actually the current situation can easily lead to a DOS situation.  I
simply have to write one application that connect to a unix socket
domain and have it send me data for which I never call recvfrom() and
voil=E0, all other consumer of this unix socket application will no mor=
e
be able to communicate with this application once it maxed out it's
sndbuf, default is 128k I believe.

I will submit my patch in my next email.

--
Yannick Koehler
