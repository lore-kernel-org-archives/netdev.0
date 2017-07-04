From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: 'skb' buffer address information leakage
Date: Tue, 4 Jul 2017 11:13:44 -0700
Message-ID: <20170704111344.416fadc5@xeon-e3>
References: <CAJsXRPEZV=ugCAxngtVRt+=GZfnwf1abxu8Q_DSaPeXuTYpsVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, qca_merez@qca.qualcomm.com,
        kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        jakub.kicinski@netronome.com, davem@davemloft.net,
        oss-drivers@netronome.com, security@kernel.org,
        wil6210@qca.qualcomm.com
To: Dison River <pwn2river@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33825 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752038AbdGDSNx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 14:13:53 -0400
Received: by mail-pf0-f179.google.com with SMTP id q85so4834337pfq.1
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 11:13:52 -0700 (PDT)
In-Reply-To: <CAJsXRPEZV=ugCAxngtVRt+=GZfnwf1abxu8Q_DSaPeXuTYpsVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Jul 2017 13:12:18 +0800
Dison River <pwn2river@gmail.com> wrote:

> Hi all:
> I'd found several address leaks of "skb" buffer.When i have a
> arbitrary address write vulnerability in kernel(enabled kASLR),I can
> use skb's address find sk_destruct's address and overwrite it. And
> then,invoke close(sock_fd) function can trigger the
> shellcode(sk_destruct func).
> 
> In kernel 4.12-rc7
> drivers/net/irda/vlsi_ir.c:326           seq_printf(seq, "skb=%p
> data=%p hw=%p\n", rd->skb, rd->buf, rd->hw);
> drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c:167
>          seq_printf(file, " frag=%p", skb);
> drivers/net/wireless/ath/wil6210/debugfs.c:926           seq_printf(s,
> "  SKB = 0x%p\n", skb);
> 
> Thanks.

Debugfs support is optional with Netronome. If concerned about security,
then it should be disabled.

The WIIL6210 driver debugfs has other worse address leaks.
The whole debugfs support in this driver should be made optional
(or removed).

The VLSI /oroc interface likewise should just be removed (or made
optional). Most distributions do not build IRDA anymore anyway.
