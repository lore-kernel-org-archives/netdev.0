From: Tom Herbert <therbert@google.com>
Subject: Re: Possible regression: "gre: Use inner mac length when computing
 tunnel length"
Date: Tue, 9 Dec 2014 13:23:54 -0800
Message-ID: <CA+mtBx-WsgMRAYDUaPiVaBt43cRx7tb-0hRJ+6Eao8vjd3j8aQ@mail.gmail.com>
References: <20141204141616.185b88c4@vostro>
	<CA+mtBx-se+u4j8WHzZ+AXeiFN2uevrvcTb6xFpeNrhjOv=EVng@mail.gmail.com>
	<20141209082645.5cf70f55@vostro>
	<20141209084425.7499dbd4@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34549 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbaLIVXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:23:55 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so1408168iec.22
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 13:23:54 -0800 (PST)
In-Reply-To: <20141209084425.7499dbd4@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 8, 2014 at 10:44 PM, Timo Teras <timo.teras@iki.fi> wrote:
> On Tue, 9 Dec 2014 08:26:45 +0200
> Timo Teras <timo.teras@iki.fi> wrote:
>
>> On Thu, 4 Dec 2014 08:00:19 -0800
>> Tom Herbert <therbert@google.com> wrote:
>>
>> > A fix is pending for net. Please try if you can.
>>
>> Finally got to testing this. Unfortunately, this does not seem to fix
>> the issue I am experiencing.
>>
>> Any suggestions?
>
> I think this fix is required, but does not fix the issue.
>
> I suspect my problem is with the fact that I have NBMA GRE tunnel.
>
> In ipgre_xmit() it is gre_handle_offloads() that is called first.
> However, in my case, the GRE header was already pushed earlier via
> header_ops. That's why the packet is skb_pull()'ed in the
> "if (dev->header_ops)" path, so that __gre_xmit can push back the
> header again on it.
>
> I wonder if it is correct to just move the gre_handle_offloads() call
> after the if() block, or if additional fixing is needed to make
> offloads work with nbma tunnels.
>
Yes, that probably is a good idea. iptunnel_handle_offloads resets
inner headers so that inner_mac header is probably wrong when there
are dev->header_ops.

Tom

> /Timo
