From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2 V3] kaweth: Fix locking to be SMP-safe
Date: Thu, 02 Apr 2009 10:02:18 -0500
Message-ID: <49D4D37A.50504@lwfinger.net>
References: <20090402100223.GA30905@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, oliver@neukum.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:38117 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763918AbZDBPDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 11:03:08 -0400
In-Reply-To: <20090402100223.GA30905@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Larry Finger <Larry.Finger@lwfinger.net> wrote:
>> @@ -796,7 +795,7 @@ static int kaweth_start_xmit(struct sk_b
>>
>>        int res;
>>
>> -       spin_lock(&kaweth->device_lock);
>> +       spin_lock_irq(&kaweth->device_lock);
> 
> Should be irqsave unless you don't expect to be called via netpoll.

The .ndo_poll_controller callback is left at NULL in this driver. I believe the
patch to be OK.

Larry
