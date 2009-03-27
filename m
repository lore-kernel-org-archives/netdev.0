From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] gianfar: fix headroom expansion code
Date: Fri, 27 Mar 2009 16:06:27 +0800
Message-ID: <2a27d3730903270106k71f01c12mf468d768f660baf7@mail.gmail.com>
References: <20090325.172139.142233386.davem@davemloft.net>
	 <20090326100856.265f7872@nehalam>
	 <2a27d3730903262126v1a0282a5u6c8ee234dff8708d@mail.gmail.com>
	 <20090327.003926.134928961.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:55456 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754649AbZC0IG3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 04:06:29 -0400
Received: by wf-out-1314.google.com with SMTP id 29so1188446wff.4
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 01:06:27 -0700 (PDT)
In-Reply-To: <20090327.003926.134928961.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2009 at 3:39 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Li Yang <leoli@freescale.com>
> Date: Fri, 27 Mar 2009 12:26:33 +0800
>
>> We have legacy devices without the offloading feature. =C2=A0And we =
can
>> even turn off the IP checksum offloading at runtime. =C2=A0Your code=
 will
>> cause unnecessary realloc for these cases.
>>
>> I can propose a new patch to fix the pointer problem and add more
>> error handling.
>
> I'm applying Stephen's patch for now, please send any improvements
> relative to that.

Ok.

However is it ok to use kfree() instead of kfree_skb() in Stephen's pat=
ch?

+               skb_new =3D skb_realloc_headroom(skb, GMAC_FCB_LEN);
+               if (!skb_new) {
+                       dev->stats.tx_errors++;
+                       kfree(skb);
+                       return NETDEV_TX_OK;
+               }

- Leo
