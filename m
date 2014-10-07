From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 7 Oct 2014 12:10:05 -0700
Message-ID: <CA+mtBx8cMt1kV6tiEd=iVKsVdZeFif_6vZZ2TDuYZPGmz5XaNw@mail.gmail.com>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
	<1412702616.11091.143.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQL_6tEhgQE9aCLe-icG4pyS1dMECGhiQ7+OHEao1GXk3g@mail.gmail.com>
	<20141007.145117.1442458821633299880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:55023 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbaJGTKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 15:10:06 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so4742226igb.8
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 12:10:05 -0700 (PDT)
In-Reply-To: <20141007.145117.1442458821633299880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 7, 2014 at 11:51 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Tue, 7 Oct 2014 11:15:32 -0700
>
> > but if HW has programmable parser it should be able to take advantage
> > of it and UNNECESSARY is an established model.
>
> Strongly disagree.


Another problem with UNNECESSARY is that the stack has no way to
validate what the HW is doing. If HW starts setting UNNECESSARY for
packets with bad checksums, this sort of bug can be really difficult
to detect. With CHECKSUM_COMPLETE it's much harder to have undetected
false positives like this, especially when we need to include pseudo
header in validation. UNNECESSARY really shouldn't be considered
robust for deployment IMO.
