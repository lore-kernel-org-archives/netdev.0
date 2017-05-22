From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] kernel: bpf: remove dead code
Date: Mon, 22 May 2017 09:51:37 -0500
Message-ID: <20170522095137.Horde.LTr0Ddp7ICoSbO3QDVcrxUX@gator4166.hostgator.com>
References: <20170522140746.GA10113@embeddedgus>
 <20170522.103800.1354089494827582585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway20.websitewelcome.com ([192.185.48.38]:18819 "EHLO
        gateway20.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934376AbdEVOvk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 10:51:40 -0400
Received: from cm14.websitewelcome.com (cm14.websitewelcome.com [100.42.49.7])
        by gateway20.websitewelcome.com (Postfix) with ESMTP id E3789400DAA4C
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 09:51:37 -0500 (CDT)
In-Reply-To: <20170522.103800.1354089494827582585.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Quoting David Miller <davem@davemloft.net>:

> From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
> Date: Mon, 22 May 2017 09:07:46 -0500
>
>> Execution cannot reach NET_IP_ALIGN inside the following statement:
>> ip_align = strict ? 2 : NET_IP_ALIGN
>>
>> Addresses-Coverity-ID: 1409762
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>> ---
>> NOTE: variable ip_align could also be removed and use value 2 directly.
>
> Incorrect.
>
> Some platforms define NET_IP_ALIGN to zero, so the code must remain
> as is.

The following piece of code at kernel/bpf/verifier.c:798 is preventing  
value NET_IP_ALIGN to be stored in variable ip_align when _strict_ is  
false:

798        if (!strict || size == 1)
799                return 0;


Thanks
