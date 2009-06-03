From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: potential null dereference in proto_register()
Date: Wed, 3 Jun 2009 11:47:53 +0000
Message-ID: <20090603114753.GA7234@ff.dom.local>
References: <20090602.025454.127590436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: error27@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f165.google.com ([209.85.218.165]:38239 "EHLO
	mail-bw0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbZFCLr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 07:47:57 -0400
Received: by bwz9 with SMTP id 9so70648bwz.37
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 04:47:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090602.025454.127590436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02-06-2009 11:54, David Miller wrote:
> From: Dan Carpenter <error27@gmail.com>
> Date: Tue, 2 Jun 2009 11:50:52 +0300 (EAT)
> 
>> There is a potential null dereference in proto_register() 
>> from net/core/sock.c
>>
>> prot->rsk_prot can be null on line 2161 but we dereference it on line 
>> 2167.
>>
>>   2161  out_free_request_sock_slab:
>>   2162          if (prot->rsk_prot && prot->rsk_prot->slab) {
>>   2163                  kmem_cache_destroy(prot->rsk_prot->slab);
>>   2164                  prot->rsk_prot->slab = NULL;
>>   2165          }
>>   2166  out_free_request_sock_slab_name:
>>   2167          kfree(prot->rsk_prot->slab_name);
>>
>> Found by smatch.
> 
> This won't ever happen because a protocol that provides a twsk_prot
> has to provide a rsk_prot too.

Then, according to smatch, we should change it:

-       if (prot->rsk_prot && prot->rsk_prot->slab) {
+       if (prot->rsk_prot->slab) {

Jarek P.
