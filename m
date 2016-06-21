From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Tue, 21 Jun 2016 16:04:18 +0300
Message-ID: <CALzJLG8+xhJDO9FaGF+9OiBq1s1LD_cb3y-ybUkFD7DJG=SRaQ@mail.gmail.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-13-git-send-email-saeedm@mellanox.com> <20160617160007.GA52082@ast-mbp.thefacebook.com>
 <CALzJLG-uoMKjZCC312JjfqnQaUW_-31eqeg0bQd+r3qp4Fa1ag@mail.gmail.com> <20160621021836.GA81638@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:33108 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcFUNFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 09:05:01 -0400
Received: by mail-yw0-f193.google.com with SMTP id i12so1655524ywa.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 06:04:39 -0700 (PDT)
In-Reply-To: <20160621021836.GA81638@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 5:18 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sat, Jun 18, 2016 at 01:31:26AM +0300, Saeed Mahameed wrote:
>>
>> We simply want to selectively be able to see RoCE/RDMA ETH standard
>> traffic in tcpdump, for diagnostic purposes.
>> so in order to not overwhelm the kernel TCP/IP stack with this
>> traffic, this patch in particular
>> configures ConnectX4 hardware to tag those packets, so in downstream
>> patches mlx5 netdevice will mark the SKBs of those packets
>> to skip the TCP/IP stack and go only to tcpdump.
>
> such 'feature' doesn't make sense to me.
> 'not overwhelming' kernel, but to 'overwhelm' userspace tcpdump?
> Kernel can drop packets way faster than userspace, so such bypass
> scheme has no prartical usage other than building a first step towards
> complete dpdk-like bypass.
>

Alexei , I don't understand your concern.
We already have a full/complete working dpdk bypass solution in
userspace nothing extra is required from the kernel.

We just want to see this traffic and any other rdma traffic in tcpdump
or other standard sniffing tools.

Anyway we brainstormed this internally today and we don't like the
"skb->protocol = 0xffff" solution,
we will suggest a plugin for libpcap in user space to extend libpcap
ability to sniff RDMA/raw eth traffic.
This way userspace RDMA traffic will be sniffed also via a userspace
RDMA channel.

I will ask Dave to drop this series.
