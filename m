From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH] ipv4: avoid undefined behavior in do_ip_setsockopt()
Date: Mon, 12 Nov 2012 12:00:54 -0500
Message-ID: <50A12B46.4010805@gmail.com>
References: <1352668801-14373-1-git-send-email-xi.wang@gmail.com><20121111.170247.780516266044882867.davem@davemloft.net><50A0244F.1070302@gmail.com> <20121111.175056.930119228369321440.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B709E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:49016 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab2KLRBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 12:01:03 -0500
Received: by mail-vb0-f46.google.com with SMTP id ff1so6443850vbb.19
        for <netdev@vger.kernel.org>; Mon, 12 Nov 2012 09:01:02 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B709E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/12/12 8:54 AM, David Laight wrote:
> 'All modern' is probably an overstatement, 'recent gcc' might be valid.

I agree if you consider gcc 3.4 released 8 years ago as "recent gcc",
or if you use a compiler other than gcc/clang/icc to compile the kernel.

> The 'switch' version will have an extra conditional to detect
> 'out of range' values - even though we know they can't happen.
> I'm not sure you can avoid that - even for an enum.

This out-of-range check is exactly what this patch wanted to add:
optname is a syscall parameter, and we should reject invalid optname
values before doing (1<<optname).

- xi
