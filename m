From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Wed, 20 Mar 2013 20:07:21 -0400
Message-ID: <CA+FuTScnkvSZ1U=vmELNEpS4hU62iMV7B2ZDHT8KGAwxCxA-Ng@mail.gmail.com>
References: <CA+FuTSeN1wXrSP8-piCdnv8MuqgokndSYsiidvdtC=d2tCqcDQ@mail.gmail.com>
 <1363761764-4374-1-git-send-email-willemb@google.com> <20130320.123344.1566685302188091721.davem@davemloft.net>
 <20130320.135934.156565403641352244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:44180 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab3CUAHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 20:07:51 -0400
Received: by mail-ie0-f170.google.com with SMTP id c11so2911169ieb.29
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 17:07:51 -0700 (PDT)
In-Reply-To: <20130320.135934.156565403641352244.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 1:59 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 20 Mar 2013 12:33:44 -0400 (EDT)
>
>> From: Willem de Bruijn <willemb@google.com>
>> Date: Wed, 20 Mar 2013 02:42:44 -0400
>>
>>> Fix flaky results with PACKET_FANOUT_HASH depending on whether the
>>> two flows hash into the same packet socket or not.
>>>
>>> Also adds tests for PACKET_FANOUT_LB and PACKET_FANOUT_CPU and
>>> replaces the counting method with a packet ring.
>>>
>>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>>
>> Applied, thanks.  I'll retest on my sparc64 box later today.
>
> Unfortunately, it's still broken there:

This looks like a new problem. Now the counters all stay zero.

I am looking into it. I have not been able to reproduce this on my
x86_64 so far, so just brought a sparc32 up in qemu. Had less luck
with sparc64, but impressive that it works at all. Come to think of
it, is this a 64-bit kernel with 32-bit userland? Perhaps that
affects packet ring memory layout.


> --------------------
> running psock_fanout test
> --------------------
> test: control single socket
> test: control multiple sockets
> test: datapath 0x0
> info: count=0,0, expect=0,0
> info: count=0,0, expect=15,5
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,5
> ERROR: incorrect queue lengths
> info: trying alternate ports (4)
> test: datapath 0x0
> info: count=0,0, expect=0,0
> info: count=0,0, expect=15,5
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,5
> ERROR: incorrect queue lengths
> info: trying alternate ports (3)
> test: datapath 0x0
> info: count=0,0, expect=0,0
> info: count=0,0, expect=15,5
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,5
> ERROR: incorrect queue lengths
> info: trying alternate ports (2)
> test: datapath 0x0
> info: count=0,0, expect=0,0
> info: count=0,0, expect=15,5
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,5
> ERROR: incorrect queue lengths
> info: trying alternate ports (1)
> test: datapath 0x0
> info: count=0,0, expect=0,0
> info: count=0,0, expect=15,5
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,5
> ERROR: incorrect queue lengths
> info: trying alternate ports (0)
> test: datapath 0x0
> info: count=0,0, expect=0,0
> info: count=0,0, expect=15,5
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,5
> ERROR: incorrect queue lengths
> test: datapath 0x1000
> info: count=0,0, expect=0,0
> info: count=0,0, expect=15,5
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,15
> ERROR: incorrect queue lengths
> test: datapath 0x1
> info: count=0,0, expect=0,0
> info: count=0,0, expect=10,10
> ERROR: incorrect queue lengths
> info: count=0,0, expect=18,17
> ERROR: incorrect queue lengths
> test: datapath 0x3
> info: count=0,0, expect=0,0
> info: count=0,0, expect=20,0
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,15
> ERROR: incorrect queue lengths
> test: datapath 0x2
> info: count=0,0, expect=0,0
> info: count=0,0, expect=20,0
> ERROR: incorrect queue lengths
> info: count=0,0, expect=20,0
> ERROR: incorrect queue lengths
> test: datapath 0x2
> info: count=0,0, expect=0,0
> info: count=0,0, expect=0,20
> ERROR: incorrect queue lengths
> info: count=0,0, expect=0,20
> ERROR: incorrect queue lengths
> [FAIL]
