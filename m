From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 7 Oct 2014 10:18:25 -0700
Message-ID: <CAADnVQJUhEmER7C_OOs0dM_mD8REbYT89SG1dfu2b79AUn9eow@mail.gmail.com>
References: <CAADnVQLkWrjN=MgtU_8zBrGFW1eJd01hd6BM_m9iOq=ypHvSLQ@mail.gmail.com>
	<20141007.130504.1805673129740661479.davem@davemloft.net>
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
Received: from mail-qg0-f49.google.com ([209.85.192.49]:62443 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858AbaJGRS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 13:18:26 -0400
Received: by mail-qg0-f49.google.com with SMTP id a108so5678418qge.8
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 10:18:25 -0700 (PDT)
In-Reply-To: <20141007.130504.1805673129740661479.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 7, 2014 at 10:05 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Tue, 7 Oct 2014 09:50:50 -0700
>
>> CHECKSUM_COMPLETE is a burden on software.
>
> I totally disagree, it's the most software friendly checksumming
> offload mechanism possible.  I wish every card did it.
>
> CHECKSUM_COMPLETE means that any sub-protocol or tunneling mechanism
> can be trivially supported without any modifications to hardware, and
> it therefore makes checksum offloading of new protocols require no
> hardware changes whatsoever.

yes, of course. My point is that if HW can parse the packet and validate
csum it should do that, since it's faster for the stack on top.
HW can fall back to CHECKSUM_COMPLETE if it fails to parse, for example.
I think some NICs do exactly that.
