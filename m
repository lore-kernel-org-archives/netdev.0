From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Fri, 17 Jun 2016 16:34:17 -0700
Message-ID: <CANn89iLytk1fefd5kwUYHk8UXg_-LE_NOz6xxqMRSHRGkzDrZA@mail.gmail.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-13-git-send-email-saeedm@mellanox.com> <20160617160007.GA52082@ast-mbp.thefacebook.com>
 <CALzJLG-uoMKjZCC312JjfqnQaUW_-31eqeg0bQd+r3qp4Fa1ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:33436 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbcFQXeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 19:34:19 -0400
Received: by mail-yw0-f173.google.com with SMTP id g20so84815307ywb.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 16:34:19 -0700 (PDT)
In-Reply-To: <CALzJLG-uoMKjZCC312JjfqnQaUW_-31eqeg0bQd+r3qp4Fa1ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 3:31 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Fri, Jun 17, 2016 at 7:00 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Fri, Jun 17, 2016 at 05:43:53PM +0300, Saeed Mahameed wrote:
>>> From: Maor Gottlieb <maorg@mellanox.com>
>>>
>>> Add kernel offload flow tag for packets that will bypass the kernel
>>> stack, e.g (RoCE/RDMA/RAW ETH (DPDK), etc ..).
>>
>> so the whole series is an elaborate way to enable dpdk? how nice.
>
> NO, God forbids! the whole series has nothing to do with dpdk!
> Please read the cover letter.
>
> Quoting my own words from the cover letter:
> "This patch set introduces mlx5 RoCE/RDMA packet sniffer, it allows
> mlx5e netdevice to receive RoCE/RDMA or RAW ETH traffic which isn't
> supposed to be passed to the kernel stack, for sniffing and diagnostics
> purposes."
>
> We simply want to selectively be able to see RoCE/RDMA ETH standard
> traffic in tcpdump, for diagnostic purposes.
> so in order to not overwhelm the kernel TCP/IP stack with this
> traffic, this patch in particular
> configures ConnectX4 hardware to tag those packets, so in downstream
> patches mlx5 netdevice will mark the SKBs of those packets
> to skip the TCP/IP stack and go only to tcpdump.
>
> DPDK is not enabled/disabled or even slightly affected in this series.
> It was just given as an example in this patch commit message for
> traffic that can be sniffed in standard tools such as tcpdump.
>
> Today there are some bad usages and abuse to skb->protocol where some
> device drivers set skb->protocol = 0xffffff to skip the kernel TCP/IP
> processing for the same diagnostic purposes.
> In this series we are just trying to do the right thing.

Well, your patch adds an extra test in kernel fast path, just to ease
the life of people using kernel bypass,
but willing to use tcpdump because they can not figure to do this in
user space properly.

Please find a way  _not_ adding a single instruction in kernel fast path.

Thanks.
