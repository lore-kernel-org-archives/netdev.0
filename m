From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 7 Oct 2014 09:50:50 -0700
Message-ID: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@nicira.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:53464 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbaJGQuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:50:51 -0400
Received: by mail-qc0-f180.google.com with SMTP id x3so6044328qcv.39
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 09:50:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2014 at 5:17 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, Oct 6, 2014 at 3:33 PM, Jesse Gross <jesse@nicira.com> wrote:
>
>> I have no disagreement with trying to be generic across protocols. I'm
>> just not convinced that it is a realistic plan. It's obvious that it
>> is not doable today nor will be it be in the next generation of NICs
>> (which are guaranteed to add support for new protocols). Furthermore,
>> there will be more advanced stuff coming in the future that I think
>> will be difficult or impossible to make protocol agnostic. Rather than
>> pretending that this doesn't exist or will never happen, it's better
>> focus on how to integrating it cleanly.
>
> Sorry, but I don't understand how supporting a new protocols in a
> device for the purposes of returning CHECKSUM_UNNECESSARY is better or
> easier to implement than just returning CHECKSUM_COMPLETE. Same thing
> for trying to use NETIF_F_IP_CSUM with encapsulation rather than
> NETIF_F_HW_CSUM. I'm not a hardware guy, so it's possible I'm missing
> something obvious...

it's definitely more difficult to properly implement
CHECKSUM_UNNECESSARY in HW, but it's worth it.
CHECKSUM_COMPLETE is a burden on software. Old NICs
used to do that, but overhead of recomputing csum for every
step of packet parsing and header modifications is too high.
sw routers, bridges and < L4 networking devices are
simpler and faster with CHECKSUM_UNNECESSARY.
