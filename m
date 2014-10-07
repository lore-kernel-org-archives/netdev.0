From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 07 Oct 2014 10:23:36 -0700
Message-ID: <1412702616.11091.143.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, Jesse Gross <jesse@nicira.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:43184 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524AbaJGRXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:23:52 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so6269126qcv.10
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 10:23:51 -0700 (PDT)
In-Reply-To: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-07 at 09:50 -0700, Alexei Starovoitov wrote:

> it's definitely more difficult to properly implement
> CHECKSUM_UNNECESSARY in HW, but it's worth it.
> CHECKSUM_COMPLETE is a burden on software. Old NICs
> used to do that, but overhead of recomputing csum for every
> step of packet parsing and header modifications is too high.
> sw routers, bridges and < L4 networking devices are
> simpler and faster with CHECKSUM_UNNECESSARY.

Really this is wrong. Once you validated/pulled a header,
adjusting the complete checksum is in the order of 10 cycles or so,
ie less than 1% of the other costs.

UNNECESSARY usually requests complex NIC firmware, and usually the NIC
has fewer cores than the host.

It mostly worked for basic IP+TCP kind of traffic, but once you want
complex cloud models, it is a major pain.

If we need to optimize csum_partial() for short lengths, lets do it,
instead of pushing hardware vendors adding more and more schemes.
