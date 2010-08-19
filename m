From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: IPsec: Why do pfkey_getspi and xfrm_alloc_userspi call xfrm_find_acq_byseq?
Date: Thu, 19 Aug 2010 14:55:21 +0200
Message-ID: <4C6D29B9.5070403@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45900 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab0HSM54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 08:57:56 -0400
Received: by wwi17 with SMTP id 17so2422842wwi.1
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 05:57:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear netdev developers,

The call to xfrm_find_acq_byseq() by the pfkey_getspi() and 
xfrm_alloc_userspi() functions is quite costly and proves to entail 
scalability issues when performing thousands of IKE negotiations with 
racoon (from ipsec-tools distribution) or charon (from strongswan 
distribution).

Removing this call in the kernel drastically accelerates the processing 
and does not seem to entail functional problems.

For now, I don't see the point of this call. I need to understand its 
purpose, because I'm highly tempted to simply remove it.

Regards,
Christophe

> Dear netdev developers,
>
> I would like to understand why the pfkey_getspi and xfrm_alloc_userspi
> functions call xfrm_find_acq_byseq() and try to find an reuse an SA in
> state XFRM_STATE_ACQ with the same sequence number and destination
> address as the GETSPI request.
>
> As far as I understand, SAs in state XFRM_STATE_ACQ can only be created
> as a result of a user call to GETSPI or a kernel ACQUIRE message.
> - GETSPI is invoked by an application in order to create a temporary SA
> with a unique SPI, typically during an IKE negotiation, to create the
> inbound SA of the pair. No later GETSPI will be done on this SA.
> - An acquire message is triggered by the kernel and creates a temporary
> outbound SA whose SPI will be chosen by the remote IKE peer.
> No later GETSPI will be done on this SA.
>
> In which case can GETSPI find and reuse an SA that matches the message
> sequence number and destination address?
> A second lookup is done just after, with xfrm_find_acq (this function
> uses a hash table). Wouldn't this lookup find this SA too?
>
> The call to xfrm_find_acq_byseq is quite costly (the whole SAD is looked
> up every time GETSPI is called), so I'd like to understand what its
> purpose is.
>
> Thanks in advance,
>
> Christophe
