From: crquan <crquan@gmail.com>
Subject: Re: [PATCH] dev-alloc-name-by-check-name-existence.patch
Date: Sat, 24 May 2014 19:58:12 -0700
Message-ID: <CAH5vBdKc09Oseb2P=K9X2xqzy4UYHtKW5UCS+9NV_EyYEKJxDA@mail.gmail.com>
References: <1400968011-13023-1-git-send-email-crquan@gmail.com> <20140524.175727.1149146448761347899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Networking Team <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:52182 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbaEYC6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 22:58:33 -0400
Received: by mail-we0-f177.google.com with SMTP id x48so6544943wes.36
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 19:58:32 -0700 (PDT)
In-Reply-To: <20140524.175727.1149146448761347899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 24, 2014 at 2:57 PM, David Miller <davem@davemloft.net> wrote:
> The cost is iterating creating the string over and over again
> and then doing the hash lookup each time.

The original code calls sscanf / snprintf / strncmp for each existing intf,
new code is not creating the string, it calls snprintf only, and it won't call
more than original times of snprintf, right? I think here it depends on
hash lookup performance,

>
> Whereas the bitmap lookup is one word sized load for every
> BITS_PER_LONG indexes checked.
>
> Did you even test your change with large numbers of devices?

the worst case might be "eth0", "eth1", ... "eth4096", ... all exists, and
try to allocate next "eth%d", then it equals to N times hash lookup,
in general case, if allocating for a different prefix "veth%d" or not
all sequential
existing, it returns faster

The benefit is not requiring extra page of memory
