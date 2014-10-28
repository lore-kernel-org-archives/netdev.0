From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] udp: Reset flow table for flows over
 unconnected sockets
Date: Tue, 28 Oct 2014 12:59:58 -0700
Message-ID: <1414526398.631.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+mtBx_V3WT1bbXY9F731GNdDdb3+ebHwj9hRyVEFynAPYhSXg@mail.gmail.com>
	 <1414451970.2922.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_eQKOkM-0PEXG2WEMosXDtqHgwT3j7NnQpP62KdZeJKQ@mail.gmail.com>
	 <20141028.005121.1715627351754245965.davem@davemloft.net>
	 <CA+mtBx9=xTyqTXrZODi9dyN1H0W51uqvHR4YT3DhFXpdc4FMbw@mail.gmail.com>
	 <1414517910.631.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx_+cxm9DgH2WHJWeHMBx9oxnRFNRunBcy32Jz4yj_DYuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:40106 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaJ1T77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 15:59:59 -0400
Received: by mail-pd0-f175.google.com with SMTP id y13so1410932pdi.6
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 12:59:59 -0700 (PDT)
In-Reply-To: <CA+mtBx_+cxm9DgH2WHJWeHMBx9oxnRFNRunBcy32Jz4yj_DYuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-28 at 12:07 -0700, Tom Herbert wrote:

> As I said, for some applications (like DNS which I suspect you're
> basically emulating) it is infeasible to size the table. Try disabling
> RFS for your test.

Well, we already did experiments.

- DNS servers are using kernel bypass.
  Damn faster than SO_REUSEPORT on UDP anyway (Ying Cai is working on
this problem, since QUIC does not yet use kernel bypass and wants
FQ/pacing)

- Disable RFS for non TCP flows.

- Or have separate hash tables for TCP/UDP (slightly same effect, as UDP
table is mostly empty in our case)


Disabling RFS is the on/off behavior you seem to push, nice for
benchmarks without hassle.

I will no longer comment on this thread, it appears we disagree and wont
find an agreement.
