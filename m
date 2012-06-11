From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [BUG report] net.core.rmem_default is larger than net.core.rmem_max
Date: Mon, 11 Jun 2012 10:06:03 +0800
Message-ID: <4FD5528B.7020301@gmail.com>
References: <4F9A676A.8070406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:34915 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab2FKCEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 22:04:50 -0400
Received: by dady13 with SMTP id y13so4712711dad.19
        for <netdev@vger.kernel.org>; Sun, 10 Jun 2012 19:04:49 -0700 (PDT)
In-Reply-To: <4F9A676A.8070406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Shan Wei said, at 2012/4/27 17:31:

> 
> It's unconventional that "default" value  is greater than "max". :-(
> 
> net.core.rmem_max = 131071
> net.core.rmem_default = 229376


ping......

I have no idea to fix this. 
Maybe add rmem_max value to be greater than rmem_default?
Eric, can you look into this?


> 
> net.core.wmem_max = 131071
> net.core.wmem_default = 229376
> 
> 
> And bisect the code to find the following commit caused this phenomenon.
> This patch increase SK_WMEM_MAX and SK_RMEM_MAX which are used to 
> initialize them.
> But rmem_max and wmem_max value are still be covered according the RAM size
> in sk_init().
> 
> 87fb4b7b533073eeeaed0b6bf7c2328995f6c075 is the first bad commit
> commit 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Thu Oct 13 07:28:54 2011 +0000
> 
>     net: more accurate skb truesize
> 
> 
