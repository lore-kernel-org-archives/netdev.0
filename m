From: Greg KH <greg@kroah.com>
Subject: Re: 'skb' buffer address information leakage
Date: Tue, 4 Jul 2017 09:44:42 +0200
Message-ID: <20170704074442.GA21877@kroah.com>
References: <CAJsXRPEZV=ugCAxngtVRt+=GZfnwf1abxu8Q_DSaPeXuTYpsVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, qca_merez@qca.qualcomm.com,
        kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        jakub.kicinski@netronome.com, davem@davemloft.net,
        oss-drivers@netronome.com, security@kernel.org,
        wil6210@qca.qualcomm.com
To: Dison River <pwn2river@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJsXRPEZV=ugCAxngtVRt+=GZfnwf1abxu8Q_DSaPeXuTYpsVw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 04, 2017 at 01:12:18PM +0800, Dison River wrote:
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

Irda doesn't even work, and will crash, so it's a bit hard to see this
as a "leakage" :)

I'm going to be ripping irda out soon anyway, so this isn't a real
issue.

> drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c:167
>          seq_printf(file, " frag=%p", skb);
> drivers/net/wireless/ath/wil6210/debugfs.c:926           seq_printf(s,
> "  SKB = 0x%p\n", skb);


debugfs is by nature, root-only access, so the potential for issues here
is lower than "any user can get this info".  That being said, patches
for these are always appreciated.

I also need to respin my "turn %p pointers off" patchset to prevent
future stuff like this from happening.  I want to get to that after
4.13-rc1 is out.

thanks,

greg k-h
