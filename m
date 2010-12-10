From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Fri, 10 Dec 2010 15:18:11 +0100
Message-ID: <AANLkTi=7NLkHW6c88gUcyW8i0Wwmf2Cw4NdmRiGci4kE@mail.gmail.com>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	<1291906948.19763.16.camel@localhost>
	<AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
	<20101209.113806.71114756.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, srk@ti.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:62254 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126Ab0LJOSN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 09:18:13 -0500
Received: by vws16 with SMTP id 16so2224208vws.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 06:18:12 -0800 (PST)
In-Reply-To: <20101209.113806.71114756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/9 David Miller <davem@davemloft.net>:
> From: Micha=B3 Miros=B3aw <mirqus@gmail.com>
> Date: Thu, 9 Dec 2010 19:47:57 +0100
>> Isn't that condition too broad? If the data could change after packe=
t
>> is submitted to the driver then results would be unpredictable and
>> allow sending wrong data with correct (because hw-calculated)
>> checksum.
> They are intentionally like that, without question.
>
> Otherwise we'd need to interlock with all application mapped,
> filesystem, and other page writes while sending any page over the
> network.
>
> We absolutely do not want to have to freeze every page we try to send
> via sendfile() or similar, the cost is just too high.
>
> If the application or networked filesystem needs such synchronization=
,
> it provides it for itself.
>
> For example, SAMBA only uses sendfile() when the file has an op-lock
> held on it.
>
> The checksum requirement for using SG is not going away, so continuin=
g
> to discuss along the lines of removing that requirement is not a good
> use of your time I don't think.

I'm trying to understand the dependency because it looks artificial for=
 me.

Unless I totally misunderstood, you say that we accept bogus data to
being sent using sendfile(). If yes, then we might as well allow
broken checksum (CPU calculated, before data changed and then was sent
to network).

If the splice/sendfile is taken out of the picture, are there any
other scenarios, when data pages could be changed after
ndo_start_xmit() entry and before TX DMA completion (between dma_map
=2E. dma_unmap)? And is it really what can happen with splice/sendfile?

Best Regards,
Micha=B3 Miros=B3aw
