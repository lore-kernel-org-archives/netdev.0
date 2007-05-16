From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small
	packets xmits
Date: Wed, 16 May 2007 18:52:12 -0400
Message-ID: <1179355932.4084.19.camel@localhost>
References: <adahcqdpz1p.fsf@cisco.com>
	 <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
	 <20070515.143207.80029051.davem@davemloft.net>
	 <1179267467.4080.33.camel@localhost>
	 <1179353523.10414.12.camel@w-sridhar2.beaverton.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xma@us.ibm.com,
	rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	ashwin.chaugule@celunite.com,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Gagan Arneja <gagan@vmware.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:46521 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762598AbXEPWwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 18:52:16 -0400
Received: by an-out-0708.google.com with SMTP id d18so82454and
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 15:52:16 -0700 (PDT)
In-Reply-To: <1179353523.10414.12.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-16-05 at 15:12 -0700, Sridhar Samudrala wrote:
> Jamal,
> 
> Here are some comments i have on your patch.
> See them inline.
> 

Thanks for taking the time Sridhar.

> try_tx_pkts() is directly calling the device's batch xmit routine.
> Don't we need to call dev_hard_start_xmit() to handle dev_queue_xmit_nit
> and GSO segmentation?
> 

I think this is the core of all your other comments.
Good catch - that piece of code has changed since 2.6.18; so the patch
i posted wont work with GSO.

You actually caught a bug in my other patch as well that nobody else
did;->

I will have to think a bit about this; i may end up coalescing when
grabbing the packets but call the nit from the driver using a helper.

cheers,
jamal

