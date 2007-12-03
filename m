From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH (resubmit)] Fix inet_diag.ko register vs rcv race
Date: Mon, 03 Dec 2007 12:01:06 +0300
Message-ID: <4753C5D2.1050704@openvz.org>
References: <474EB825.8000601@openvz.org> <20071203045622.GA20636@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46618 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbXLCJBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 04:01:38 -0500
In-Reply-To: <20071203045622.GA20636@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Nov 29, 2007 at 04:01:25PM +0300, Pavel Emelyanov wrote:
>> @@ -863,13 +861,13 @@ int inet_diag_register(const struct inet_diag_handler *h)
>>  	if (type >= INET_DIAG_GETSOCK_MAX)
>>  		goto out;
>>  
>> -	spin_lock(&inet_diag_register_lock);
>> +	mutex_lock(&inet_diag_mutex);
>>  	err = -EEXIST;
>>  	if (inet_diag_table[type] == NULL) {
>>  		inet_diag_table[type] = h;
>>  		err = 0;
>>  	}
>> -	spin_unlock(&inet_diag_register_lock);
>> +	mutex_unlock(&inet_diag_mutex);
> 
> Actually this causes a dead-lock when the handlers are built as modules
> because we try to load them with that mutex held.

Ouch! Sorry, I didn't notice this :(

> I've fixed it with this patch on top.

Thanks!

> Cheers,

Pavel

