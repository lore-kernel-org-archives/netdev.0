From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mcs7780: Silence uninitialized variable warning
Date: Mon, 31 Jul 2017 10:37:16 -0700 (PDT)
Message-ID: <20170731.103716.2203333144439591434.davem@davemloft.net>
References: <20170728144511.tf7nc672hwo35rnn@mwanda>
        <20170729.232855.1831311386560187695.davem@davemloft.net>
        <20170731070925.ztlfbyd7pvoz46wh@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42564 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdGaRhT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 13:37:19 -0400
In-Reply-To: <20170731070925.ztlfbyd7pvoz46wh@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 31 Jul 2017 10:41:40 +0300

> On Sat, Jul 29, 2017 at 11:28:55PM -0700, David Miller wrote:
>> From: Dan Carpenter <dan.carpenter@oracle.com>
>> Date: Fri, 28 Jul 2017 17:45:11 +0300
>> 
>> > -	__u16 rval;
>> > +	__u16 rval = -1;
>> 
>> Fixing a bogus warning by assigning a signed constant to an
>> unsigned variable doesn't really make me all that happy.
>> 
>> I don't think I'll apply this, sorry.
> 
> There's no guarantee that small kmallocs will always succeed in future
> kernels so it's not *totally* bogus.

Perhaps the burdon of initializing the value belongs in
mcs_get_reg(), and you can set it properly to 0xffff
instead of -1.

Ok?
