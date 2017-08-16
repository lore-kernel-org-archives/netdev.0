From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 00/10] BPF: sockmap and sk redirect support
Date: Wed, 16 Aug 2017 17:25:14 +0200
Message-ID: <599463DA.9050302@iogearbox.net>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, tom@herbertland.com
To: John Fastabend <john.fastabend@gmail.com>, davem@davemloft.net,
        ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34488 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751517AbdHPPZU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:25:20 -0400
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2017 07:30 AM, John Fastabend wrote:
> This series implements a sockmap and socket redirect helper for BPF
> using a model similar to XDP netdev redirect. A sockmap is a BPF map
> type that holds references to sock structs. Then with a new sk
> redirect bpf helper BPF programs can use the map to redirect skbs
> between sockets,
>
>        bpf_sk_redirect_map(map, key, flags)
>
> Finally, we need a call site to attach our BPF logic to do socket
> redirects. We added hooks to recv_sock using the existing strparser
> infrastructure to do this. The call site is added via the BPF attach
> map call. To enable users to use this infrastructure a new BPF program
> BPF_PROG_TYPE_SK_SKB is created that allows users to reference sock
> details, such as port and ip address fields, to build useful socket
> layer program. The sockmap datapath is as follows,
>
>       recv -> strparser -> verdict/action
>
> where this series implements the drop and redirect actions.
> Additional, actions can be added as needed.
>
> A sample program is provided to illustrate how a sockmap can
> be integrated with cgroups and used to add/delete sockets in
> a sockmap. The program is simple but should show many of the
> key ideas.
>
> To test this work test_maps in selftests/bpf was leveraged.
> We added a set of tests to add sockets and do send/recv ops
> on the sockets to ensure correct behavior. Additionally, the
> selftests tests a series of negative test cases. We can expand
> on this in the future.
>
> I also have a basic test program I use with iperf/netperf
> clients that could be sent as an additional sample if folks
> want this. It needs a bit of cleanup to send to the list and
> wasn't included in this series.
>
> For people who prefer git over pulling patches out of their mail
> editor I've posted the code here,
>
> https://github.com/jrfastab/linux-kernel-xdp/tree/sockmap
>
> For some background information on the genesis of this work
> it might be helpful to review these slides from netconf 2017
> by Thomas Graf,
>
> http://vger.kernel.org/netconf2017.html
> https://docs.google.com/a/covalent.io/presentation/d/1dwSKSBGpUHD3WO5xxzZWj8awV_-xL-oYhvqQMOBhhtk/edit?usp=sharing
>
> Thanks to Daniel Borkmann for reviewing and providing initial
> feedback.

LGTM, for the set:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
