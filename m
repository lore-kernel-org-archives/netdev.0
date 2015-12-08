From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Tue, 8 Dec 2015 08:43:04 -0800
Message-ID: <CALx6S37T8gA8ZNRTgWt5MBW8QLYa7ODnAoZm-=Xk5VNg_t3QSg@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<CALx6S37+YVqpVL6XX2KCHZad84DGpqpL+K4LdDZr5H-feiyjow@mail.gmail.com>
	<5666FF46.6030702@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:38397 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933318AbbLHQnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 11:43:05 -0500
Received: by igbxm8 with SMTP id xm8so21079675igb.1
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 08:43:04 -0800 (PST)
In-Reply-To: <5666FF46.6030702@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 8:03 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 07/12/15 17:29, Tom Herbert wrote:
>> On Mon, Dec 7, 2015 at 7:39 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> 2) Transmit checksums.
>> It's analogous to CHECKSUM_COMPLETE, NETIF_F_HW_CSUM works for all
>> cases of checksum offload and any combination of protocol layering.
> ... until a protocol combination comes along that doesn't allow all but the innermost checksum to be 0.  NETIF_F_HW_CSUM is limited to one checksum per packet.

So is NETIF_F_IP[V6]_CSUM, again the interface into the driver to
offload a checksum is csum_start, csum_offset. Only one checksum can
be offloaded at a time. We have no way to tell the driver that there
are two checksums in a packet to be offloaded. Good news is that we
probably don't need that. Extensible encapsulation protocols can
implement Remote Checksum Offload, and this is never an issue on the
receive side since CHECKSUM_COMPLETE can be used to validate and
arbitrary number of checksums.

Tom
