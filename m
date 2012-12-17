From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: XFRM: Could we change ESP padding?
Date: Mon, 17 Dec 2012 07:43:02 +0100
Message-ID: <20121217064302.GK18940@secunet.com>
References: <CAJFZqHzDDtUacnQzd-gcS8JBvPdgspozWkUFOogS4nDmvZz7rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43250 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141Ab2LQGnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 01:43:08 -0500
Content-Disposition: inline
In-Reply-To: <CAJFZqHzDDtUacnQzd-gcS8JBvPdgspozWkUFOogS4nDmvZz7rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2012 at 11:28:05AM +0800, RongQing Li wrote:
> Hi:
> 
> setkey has the below parameter, but this parameter seems not be
> implemented in kernel and userspace,
> 	
>      -f pad_option  defines the content of the ESP padding.
> pad_option is one of following:
>         zero-pad    All the paddings are zero.
>         random-pad  A series of randomized values are used.
>         seq-pad     A series of sequential increasing numbers
>  started from 1 are used.
> 

We can not implement this. As you already mentioned, RFC 4303
makes strong statements on how the padding bytes are initialized.
An IPsec implementation that checks the padding bytes would drop our
packets if we don't use the padding method described in RFC 4303.

> 
> and kernel seems not inspect the ESP padding content too, the result
> is the packets are not dropped even if they are with a wrong pad
> content(not a monotonically increasing sequence).
> 
> 
> Could anyone tell me why, bad description in RFC, performance, lack time,
> or other reason? Thanks very much!
> 

RFC 4303 says that the receiver should inspect the padding field,
so we are free to do it or not. You can find a comment that explains
why we don't do it in the esp_input_done2() function ;-) 
