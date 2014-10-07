From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Tue, 7 Oct 2014 09:33:04 -0700
Message-ID: <CAADnVQJf8jtRr3xBdSOt_X188Xkkg0EnxVd+gh6ruTMjc9jOHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willem de Bruijn <willemb@google.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Network Development <netdev@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Zhou, Danny" <danny.zhou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:44958 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921AbaJGQdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 12:33:06 -0400
Received: by mail-qc0-f170.google.com with SMTP id m20so6220545qcx.29
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2014 09:33:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 7, 2014 at 8:21 AM, Zhou, Danny <danny.zhou@intel.com> wrote:
>
> As a master driver, the NIC kernel driver still takes control of flow director as a ethtool backend. Generally,
> not all queues are initialized and used by NIC kernel driver, which reports actually used rx/tx numbers to stacks.
> Before splitting off certain queues, if you want use ethtool to direct traffics to those unused queues,
> ethtool reports invalid argument. Once certain stack-unaware queues are allocated for user space slave driver,
> ethtool allows directing packets to them as the NIC driver maintains a data struct about which queues are visible
> and used by kernel, which are used by user space.

this whole thing sounds like it's a way to let DPDK apps share physical
interfaces with kernel, so that tcp-based control plane traffic
can reach DPDK process via kernel while DPDK user space
data path does the rest of packet processing?
One still needs pcie register i/o and all of user space driver support
to make it work, right?
I guess that's great for DPDK users, but I don't think it's good for linux.
