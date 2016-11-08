From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 0/2] sfc: enable 4-tuple UDP RSS hashing
Date: Tue, 8 Nov 2016 13:02:05 +0000
Message-ID: <2c97d90b-bbb3-2cdc-7a72-597fd3f5231a@solarflare.com>
References: <ba5aa0bc-277b-5b47-89f8-fad1010b77f9@solarflare.com>
 <20161107.132003.727799156798583121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:28751 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932675AbcKHNCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 08:02:17 -0500
In-Reply-To: <20161107.132003.727799156798583121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/16 18:20, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Thu, 3 Nov 2016 22:10:31 +0000
>
>> EF10 based NICs have configurable RSS hash fields, and can be made to take the
>> ports into the hash on UDP (they already do so for TCP).  This patch series
>> enables this, in order to improve spreading of UDP traffic.
> What does the chip do with fragmented traffic?
Only the first fragment will be considered UDP, it will treat the rest as "other
IP" and 2-tuple hash them, probably hitting a different queue.

My understanding is that while that will reduce performance, that shouldn't be a
problem as performance-sensitive users will avoid fragmentation anyway.
It could also lead to out-of-order packet delivery, but it's UDP so that's
supposed to be OK.
