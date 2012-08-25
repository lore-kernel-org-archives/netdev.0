From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: [Patch] netpoll: revert 6bdb7fe3104 and fix be_poll() instead
Date: Sat, 25 Aug 2012 12:04:01 +0200
Message-ID: <CAF6-1L5KzS_AgFM4_Wc-c64e4qMzpD5tWPWokB8fP4MkfJn4-Q@mail.gmail.com>
References: <1345880471-29535-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:58231 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab2HYKED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 06:04:03 -0400
Received: by vbbff1 with SMTP id ff1so2936559vbb.19
        for <netdev@vger.kernel.org>; Sat, 25 Aug 2012 03:04:02 -0700 (PDT)
In-Reply-To: <1345880471-29535-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong,

On Sat, Aug 25, 2012 at 9:41 AM, Cong Wang <amwang@redhat.com> wrote:
> Against -net.
>
> In the patch "netpoll: re-enable irq in poll_napi()", I tried to
> fix the following warning:
>
> [100718.051041] ------------[ cut here ]------------
> [100718.051048] WARNING: at kernel/softirq.c:159 local_bh_enable_ip+0x7d/0xb0()
> (Not tainted)
> [100718.051049] Hardware name: ProLiant BL460c G7
> ...
> [100718.051068] Call Trace:
> [100718.051073]  [<ffffffff8106b747>] ? warn_slowpath_common+0x87/0xc0
> [100718.051075]  [<ffffffff8106b79a>] ? warn_slowpath_null+0x1a/0x20
> [100718.051077]  [<ffffffff810747ed>] ? local_bh_enable_ip+0x7d/0xb0
> [100718.051080]  [<ffffffff8150041b>] ? _spin_unlock_bh+0x1b/0x20
> [100718.051085]  [<ffffffffa00ee974>] ? be_process_mcc+0x74/0x230 [be2net]
> [100718.051088]  [<ffffffffa00ea68c>] ? be_poll_tx_mcc+0x16c/0x290 [be2net]
> [100718.051090]  [<ffffffff8144fe76>] ? netpoll_poll_dev+0xd6/0x490
> [100718.051095]  [<ffffffffa01d24a5>] ? bond_poll_controller+0x75/0x80 [bonding]
> [100718.051097]  [<ffffffff8144fde5>] ? netpoll_poll_dev+0x45/0x490
> [100718.051100]  [<ffffffff81161b19>] ? ksize+0x19/0x80
> [100718.051102]  [<ffffffff81450437>] ? netpoll_send_skb_on_dev+0x157/0x240
>
> by reenabling IRQ before calling ->poll, but it seems more
> problems are introduced after that patch:
>
> http://ozlabs.org/~akpm/stuff/IMG_20120824_122054.jpg
> http://marc.info/?l=linux-netdev&m=134563282530588&w=2
>
> So it is safe to fix be2net driver code directly.
>
> This patch reverts the offending commit and fixes be_poll() by
> avoid disabling BH there, this is okay because be_poll()
> can be called either by poll_napi() which already disables
> IRQ, or by net_rx_action() which already disables BH.
>
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
> Cc: Sylvain Munaut <s.munaut@whatever-company.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Tested-by: Sylvain Munaut <s.munaut@whatever-company.com>


This patch fixes my issues with netconsole, it works fine now !

I tested exact same config with and without and crashes without it,
works fine with it.
The kernel I used was a 3.6-rc3 + PMTU patch + "bnx2 NULL deref with
netpoll" patch.


Thanks a lot.

Cheers,

     Sylvain
