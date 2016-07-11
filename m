From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v6 05/12] Add sample for adding simple drop program to
 link
Date: Mon, 11 Jul 2016 07:09:26 -0400
Message-ID: <57837E66.3050000@mojatatu.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-6-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:36356 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758534AbcGKLJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 07:09:35 -0400
Received: by mail-io0-f172.google.com with SMTP id b62so532769iod.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 04:09:35 -0700 (PDT)
In-Reply-To: <1467944124-14891-6-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-07 10:15 PM, Brenden Blanco wrote:
> Add a sample program that only drops packets at the BPF_PROG_TYPE_XDP_RX
> hook of a link. With the drop-only program, observed single core rate is
> ~20Mpps.
>
> Other tests were run, for instance without the dropcnt increment or
> without reading from the packet header, the packet rate was mostly
> unchanged.
>
> $ perf record -a samples/bpf/xdp1 $(</sys/class/net/eth0/ifindex)
> proto 17:   20403027 drops/s
>


So - devil's advocate speaking:
I can filter and drop with this very specific NIC at 10x as fast
in hardware, correct?
Would a different NIC (pick something like e1000) have served a better
example?
BTW: Brenden, now that i looked closer here, you really dont have
apple-apple comparison with dropping at tc ingress. You have a
tweaked prefetch and are intentionally running things on a single
core. Note: We are able to do 20Mpps drops with tc with a single
core (as shown in netdev11) on a NUC with removing driver overhead.

cheers,
jamal
