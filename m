From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: mlx4: Bug in XDP_TX + 16 rx-queues
Date: Sun, 18 Dec 2016 12:31:30 +0200
Message-ID: <fd3b36fa-8365-3873-b3e5-fff47939c330@gmail.com>
References: <20161217101803.GB8732@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>
To: Martin KaFai Lau <kafai@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f170.google.com ([209.85.210.170]:33491 "EHLO
        mail-wj0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753594AbcLRKbd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2016 05:31:33 -0500
Received: by mail-wj0-f170.google.com with SMTP id xy5so126188162wjc.0
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2016 02:31:33 -0800 (PST)
In-Reply-To: <20161217101803.GB8732@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,


On 17/12/2016 12:18 PM, Martin KaFai Lau wrote:
> Hi All,
>
> I have been debugging with XDP_TX and 16 rx-queues.
>
> 1) When 16 rx-queues is used and an XDP prog is doing XDP_TX,
> it seems that the packet cannot be XDP_TX out if the pkt
> is received from some particular CPUs (/rx-queues).
Does the rx_xdp_tx_full counter increase?
Does the problem repro if you turn off PFC?
     ethtool -A <intf> rx off tx off
>
> 2) If 8 rx-queues is used, it does not have problem.
>
> 3) The 16 rx-queues problem also went away after reverting these
> two patches:
> 15fca2c8eb41 net/mlx4_en: Add ethtool statistics for XDP cases
> 67f8b1dcb9ee net/mlx4_en: Refactor the XDP forwarding rings scheme
>
> 4) I can reproduce the problem by running samples/bof/xdp_ip_tunnel at
> the receiver side.  The sender side sends out TCP packets with
> source port ranging from 1 to 1024.  At the sender side also, do
> a tcpdump to capture the ip-tunnel packet reflected by xdp_ip_tunnel.
> With 8 rx-queues,  I can get all 1024 packets back.  With 16 rx-queues,
> I can only get 512 packets back.  It is a 40 CPUs machine.
> I also checked the rx*_xdp_tx counters (from ethtool -S eth0) to ensure
> the xdp prog has XDP_TX-ed it out.
So all packets were transmitted (according to rx*_xdp_tx), and only half 
the of them received on the other side?
>
> Not saying that 67f8b1dcb9ee is 100% the cause because there are other
> changes since then.  It is merely a brain dump on what I have already
> tried.
>
> Tariq/Saeed, any thoughts?  I can easily test some patches in
> my setup.
>
> Thanks,
> --Martin
Thanks,
Tariq
