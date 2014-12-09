From: Timo Teras <timo.teras@iki.fi>
Subject: Re: Possible regression: "gre: Use inner mac length when computing
 tunnel length"
Date: Tue, 9 Dec 2014 08:44:25 +0200
Message-ID: <20141209084425.7499dbd4@vostro>
References: <20141204141616.185b88c4@vostro>
	<CA+mtBx-se+u4j8WHzZ+AXeiFN2uevrvcTb6xFpeNrhjOv=EVng@mail.gmail.com>
	<20141209082645.5cf70f55@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:53606 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbaLIGoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 01:44:34 -0500
Received: by mail-la0-f52.google.com with SMTP id hs14so5292941lab.11
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2014 22:44:33 -0800 (PST)
In-Reply-To: <20141209082645.5cf70f55@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Dec 2014 08:26:45 +0200
Timo Teras <timo.teras@iki.fi> wrote:

> On Thu, 4 Dec 2014 08:00:19 -0800
> Tom Herbert <therbert@google.com> wrote:
> 
> > A fix is pending for net. Please try if you can.
> 
> Finally got to testing this. Unfortunately, this does not seem to fix
> the issue I am experiencing.
> 
> Any suggestions?

I think this fix is required, but does not fix the issue.

I suspect my problem is with the fact that I have NBMA GRE tunnel.

In ipgre_xmit() it is gre_handle_offloads() that is called first.
However, in my case, the GRE header was already pushed earlier via
header_ops. That's why the packet is skb_pull()'ed in the
"if (dev->header_ops)" path, so that __gre_xmit can push back the
header again on it.

I wonder if it is correct to just move the gre_handle_offloads() call
after the if() block, or if additional fixing is needed to make
offloads work with nbma tunnels.

/Timo
