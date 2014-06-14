From: Tom Herbert <therbert@google.com>
Subject: Re: No GSOs to i40e with VXLAN
Date: Fri, 13 Jun 2014 18:59:06 -0700
Message-ID: <CA+mtBx_6BWhHm4eK2qqR737jwQHi_dyrv-Md_-_f5AEghWNAKg@mail.gmail.com>
References: <alpine.LFD.2.11.1406131657240.4926@fvl-a0.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:60395 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379AbaFNB7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 21:59:07 -0400
Received: by mail-ie0-f175.google.com with SMTP id tp5so3066804ieb.6
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2014 18:59:06 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1406131657240.4926@fvl-a0.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 13, 2014 at 5:15 PM, Joseph Gasparakis
<joseph.gasparakis@intel.com> wrote:
> Hi all,
>
> I quickly tested VXLAN on i40e with net-next with commit id
> f9da455b93f6ba076935b4ef4589f61e529ae046 and the i40e driver has stopped
> receiving GSOs even when advertising tx-udp_tnl-segmentation which means
> our VXLAN segmentation offload. I am guessing this has something to do
> with Tom's recent UDP work but this is just a guess as unfortunatly I
> do not have the time to debug this, but I am signing up to review and test
> patches fixing this issue.
>
I verified tunnel offload works properly with bnx2x (I'm using simple
vxlan interfaces not OVS).

One possibility I can think of is that UDP checksums are somehow
enabled. If you're using IPv6 this probably the case (but I assume
you're seeing this with IPv4). If checksums are inadvertently enabled
somehow in IPv4 this should should up in tcpdump on the Ethernet
interface.

Thanks,
Tom

> The driver still gets GSOs with non VXLAN traffic (tested with TCP).
>
> Thanks
>
> Joseph
