From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH/REPOST] net/mpc5200: Fix locking on fec_mpc52xx driver
Date: Tue, 8 Dec 2009 22:16:36 -0700
Message-ID: <fa686aa40912082116r7750c83cs55ccfbb4b937c095@mail.gmail.com>
References: <20091205043015.28041.19288.stgit@angua> <20091208.202838.78052287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, a.llano@ziv.es
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:34268 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbZLIFQt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 00:16:49 -0500
Received: by yxe17 with SMTP id 17so5626146yxe.33
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2009 21:16:56 -0800 (PST)
In-Reply-To: <20091208.202838.78052287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2009 at 9:28 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Fri, 04 Dec 2009 21:33:13 -0700
>
>> Fix the locking scheme on the fec_mpc52xx driver. =A0This device can
>> receive IRQs from three sources; the FEC itself, the tx DMA, and the
>> rx DMA. =A0Mutual exclusion was handled by taking a spin_lock() in t=
he
>> critical regions, but because the handlers are run with IRQs enabled=
,
>> spin_lock() is insufficient and the driver can end up interrupting
>> a critical region anyway from another IRQ.
>>
>> Asier Llano discovered that this occurs when an error IRQ is raised
>> in the middle of handling rx irqs which resulted in an sk_buff memor=
y
>> leak.
>
> I'll apply this fix.

Thanks.

> But, longer term, it's a thousand times easier and more efficient to
> move the processing of these interrupts into softirq context.

I agree.  Just need to find someone to do it.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
