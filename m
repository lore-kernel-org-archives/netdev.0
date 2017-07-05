From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [RFC] tls: length check correct in do_tls_getsockopt_tx()?
Date: Wed, 5 Jul 2017 13:17:48 +0300
Message-ID: <20170705101748.abfquxq73ey6lhme@mwanda>
References: <a0dac911-6401-12cb-611c-5a1723d943c1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, davejwatson@fb.com,
        Julia Lawall <Julia.Lawall@lip6.fr>
To: Matthias Rosenfelder <mrosenfelder.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23582 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdGEKSK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 06:18:10 -0400
Content-Disposition: inline
In-Reply-To: <a0dac911-6401-12cb-611c-5a1723d943c1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 05, 2017 at 03:10:53AM -0400, Matthias Rosenfelder wrote:
> Hi,
> 
> In do_tls_getsockopt_tx():
> 
> if (len == sizeof(crypto_info)) {
> 
> should be
> 
> if (len == sizeof(*crypto_info)) {
> 
> as crypto_info is of pointer type. Or am I missing something?

No, you're right.  It should be "sizeof(*crypto_info)".

It's hard for Smatch to catch these sorts of bugs because Sparse
sometimes just gives Smatch a number literal instead of a sizeof()
expression.  I think Coccinelle can catch these kinds of bugs?

regards,
dan carpenter
