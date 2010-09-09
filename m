From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems obtaining software TX timestamps
Date: Thu, 09 Sep 2010 16:02:38 +0200
Message-ID: <1284040958.2589.178.camel@edumazet-laptop>
References: <4C877D8A.6040002@edu.uni-klu.ac.at>
	 <1283958771.2748.85.camel@edumazet-laptop>
	 <4C87FE60.7090209@edu.uni-klu.ac.at>
	 <20100909063541.GA3305@riccoc20.at.omicron.at>
	 <4C889A1E.6050405@edu.uni-klu.ac.at>
	 <20100909135716.GA8706@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Kofler <ikofler@edu.uni-klu.ac.at>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39873 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab0IIOCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 10:02:44 -0400
Received: by fxm16 with SMTP id 16so872484fxm.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 07:02:43 -0700 (PDT)
In-Reply-To: <20100909135716.GA8706@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 septembre 2010 =C3=A0 15:57 +0200, Richard Cochran a =C3=A9=
crit :
> On Thu, Sep 09, 2010 at 10:26:06AM +0200, Ingo Kofler wrote:
> > Thank you very much for this clarification. Are there any drawbacks
> > with this approach, e.g. performance issues? Honestly, I am just
> > wondering why driver developers do not add this single line if it's
> > that easy....
>=20
> Adding the line only tests one flag, so it is not a huge performance
> hit. This fix is very recent, that is why it has not been used in MAC
> drivers yet.

Should drivers call it at start_xmit() time, or at tx completion time ?

1) start_xmit() time : Earlier than real hardware xmit (with up to 1000
packets queued in TX ring, delay might be very large)

2) tx completion time : After real hardware xmit
   (on tg3, ethtool -c gives : tx-usecs: 72  , tx-frames: 53, so we can
have a delay of 72 us before NIC acknowledges the frame xmit)



