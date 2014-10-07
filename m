From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 7 Oct 2014 13:28:01 -0700
Message-ID: <CAADnVQKKv43aBFCCaEypAosCf+8K64A2oyYEtxw4jQqY0npV5g@mail.gmail.com>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
	<20141007.130504.1805673129740661479.davem@davemloft.net>
	<CAADnVQJUhEmER7C_OOs0dM_mD8REbYT89SG1dfu2b79AUn9eow@mail.gmail.com>
	<20141007.144752.657165589422333613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>, Jesse Gross <jesse@nicira.com>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:34634 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaJGU2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:28:02 -0400
Received: by mail-qc0-f182.google.com with SMTP id i17so6416030qcy.41
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 13:28:01 -0700 (PDT)
In-Reply-To: <20141007.144752.657165589422333613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 7, 2014 at 11:47 AM, David Miller <davem@davemloft.net> wrote:
>
> I am totally against boolean "yes/no" protocol specific checksum
> validation by HW.
>
> It's not faster.  You have to look at the pseudo-header and bring it into
> the CPU cache _anyways_, so negating it and 2's complementing it into
> the CHECKSUM_COMPLETE value for validation is free.
>
> There is no performance advantage whatsoever to use another checksumming
> scheme.

ok, forget faster/slower argument for a second.
Why is it a bad thing to have HW verifying checksums?
Tom's argument of difficult bugs in firmware is valid, but there can be bugs
in hw too and in kernel stack...
Also NICs do verify csum already. What are we saying here? Stop doing it?
I can trust only kernel stack to verify csum?

btw, just remembered why COMPLETE is slow in the datacenter...
virtio doesn't have support for it. Packets going into tap without
VIRTIO_NET_HDR_F_DATA_VALID, so guests have to do whole
packet csum.
