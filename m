From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: network packet corruption in v3.6.0-rc1 (and also in v3.5)
Date: Sun, 19 Aug 2012 13:02:14 +0200
Message-ID: <1345374134.5158.103.camel@edumazet-glaptop>
References: <CA+Y=x3=jSrEaYdnaAF75p0utQq02MhoSh4SkshRVSc7JjjVPOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>, netdev@vger.kernel.org
To: Andrew Worsley <amworsley@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59553 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab2HSLCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 07:02:19 -0400
Received: by wgbdr13 with SMTP id dr13so4581328wgb.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 04:02:18 -0700 (PDT)
In-Reply-To: <CA+Y=x3=jSrEaYdnaAF75p0utQq02MhoSh4SkshRVSc7JjjVPOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-08-18 at 16:40 +1000, Andrew Worsley wrote:
> Some times I get a burst of errors and dropped tcp connections with
> this warning. I had a similar issue with v3.5 (in fact v3.5 was
> unusable for https connections which would give bad MAC code messages
> at the application level)..
> 
> The issue seems better under v3.6-rc1 where as it was very bad under
> v3.5. Let me know if there is something I can do to avoid this
> problem. I am using the USB r8712u wireless NIC if that is relevant as
> I haven't been able to get the native wireless working under the MAC
> book yet (requires proprietary firmware extraction which I am not
> familiar with)
> 
> Much obliged if there is anything I can do to avoid it as it is rather
> annoying. Doesn't happen at all with my  Debian wheezy 3.2.0-2-amd64
> kernel.

OK, this seems to be related to r8712u, still in staging tree.

At first glance, its using a buggy skb_clone(), or kind of a 'reuse skb'
trick I have no time to investigate.

I suspect that some memory area are overwritten by this driver, and this
was not noticed with older kernels. With new kernels, its triggering a
WARN_ON() in tcp stack.

Any chance you can try to reproduce the bug with another adapter ?
