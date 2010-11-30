From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Tue, 30 Nov 2010 12:51:08 +0800
Message-ID: <AANLkTin11AYaFWMArC6fNQnvej2+=WUfOtTVrtX8WLEZ@mail.gmail.com>
References: <20101129.134403.179947389.davem@davemloft.net>
 <AANLkTimwo_ok=1dfzOST=rKqQdNS95wUAVdrrZHBMddS@mail.gmail.com> <20101129.191457.193722052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38877 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046Ab0K3Ev3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:51:29 -0500
Received: by fxm8 with SMTP id 8so815246fxm.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 20:51:28 -0800 (PST)
In-Reply-To: <20101129.191457.193722052.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 11:14 AM, David Miller <davem@davemloft.net> wrote:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Tue, 30 Nov 2010 10:33:49 +0800
>
>> I have thought about converting this AVL tree to rbtree. When I saw
>> the comment above, I gave it up, because rbtree makes this structure
>> bigger. If ipv6 support is added, I think it is time to turn to
>> rbtree. :)
>
> If it takes size over 128 bytes, it is probably still a bad idea.
> Right now it is just under 128.
>

Why 128? The current size of inet_peer is 64 bytes, and after your
ipv6 patch, it is just 80. And, inet_peer is allocated from its own
mem_cache, so the size of the memory for it should not be aligned to
2^n.

If rbtree is used instead, extra 8 bytes will be needed, and the size
of inet_peer will be 88.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
