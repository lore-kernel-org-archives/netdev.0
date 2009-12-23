From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [BUG] 2.6.33-rc1 gianfar error message
Date: Wed, 23 Dec 2009 19:45:10 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA09039@zin33exm22.fsl.freescale.net>
References: <20091220214447.GA10233@trillian.comsick.at> <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net> <20091221072704.GA12110@gibson.comsick.at> <9F4C7D19E8361D4C94921B95BE08B81BA08F83@zin33exm22.fsl.freescale.net> <20091221163843.GB3529@gibson.comsick.at> <9F4C7D19E8361D4C94921B95BE08B81BA08FCA@zin33exm22.fsl.freescale.net> <20091222181000.GA71727@trillian.comsick.at> <20091222182756.GA71759@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>
To: "Michael Guntsche" <mike@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:45428 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbZLWOPP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 09:15:15 -0500
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBNEFECV001920
	for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 07:15:14 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id nBNEKlgc018767
	for <netdev@vger.kernel.org>; Wed, 23 Dec 2009 08:20:48 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091222182756.GA71759@trillian.comsick.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: Michael Guntsche [mailto:mike@it-loops.com] 
>Sent: Tuesday, December 22, 2009 11:58 PM
>To: Kumar Gopalpet-B05799
>Cc: netdev
>Subject: Re: [BUG] 2.6.33-rc1 gianfar error message
>
>On 2009.12.22 19:10:00 , Michael Guntsche wrote:
>> Since you said that the first patch is not needed
>> 
>> @@ -2470,10 +2470,11 @@ static int gfar_process_frame(struct 
>net_device
>>         fcb = (struct rxfcb *)skb->data;
>> 
>>         /* Remove the FCB from the skb */
>> -       skb_set_queue_mapping(skb, fcb->rq);
>>         /* Remove the padded bytes, if there are any */
>> -       if (amount_pull)
>> +       if (amount_pull) {
>> +               skb_set_queue_mapping(skb, fcb->rq);
>>                 skb_pull(skb, amount_pull);
>> +       }
>> 
>>         if (priv->rx_csum_enable)
>>                 gfar_rx_checksum(skb, fcb);
>> 
>> I only applied the second one and tested again. Right after 
>the reboot 
>> I got an error so apparently this change IS required as well.
>
>I tested this now in the opposite direction and apparently 
>ONLY this patch is needed. I commented out the second diff and 
>did not get any errors so far. Sorry for not testing this 
>before sending my previous mail.
>

Ok. Thanks !

>Kind regards,
>Michael
>
>
