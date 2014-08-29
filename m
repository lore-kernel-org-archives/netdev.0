From: Cong Wang <cwang@twopensource.com>
Subject: Re: RTNL: assertion failed at net/ipv6/addrconf.c (1699)
Date: Fri, 29 Aug 2014 15:54:48 -0700
Message-ID: <CAHA+R7PLR7QHZuPriCErpuYL2_T+EiMhKF=qEKXjdgubno_StA@mail.gmail.com>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
	<CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
	<20140829195339.GA9780@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:59699 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbaH2Wyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 18:54:50 -0400
Received: by mail-la0-f53.google.com with SMTP id s18so3537924lam.12
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 15:54:48 -0700 (PDT)
In-Reply-To: <20140829195339.GA9780@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 29, 2014 at 12:53 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> 2014-08-29, 11:14:48 -0700, Cong Wang wrote:
>> On Fri, Aug 29, 2014 at 8:26 AM, Tommi Rantala <tt.rantala@gmail.com> wrote:
>> > [   77.297196] RTNL: assertion failed at net/ipv6/addrconf.c (1699)
>> > [   77.298080] CPU: 0 PID: 4842 Comm: trinity-main Not tainted 3.17.0-rc2+ #30
>> > [   77.299039] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> > [   77.299789]  ffff88003d76a618 ffff880026133c50 ffffffff8238ba79
>> > ffff880037c84520
>> > [   77.300829]  ffff880026133c90 ffffffff820bd52b 0000000000000000
>> > ffffffff82d86c40
>> > [   77.301869]  0000000000000000 00000000f76fd1e1 ffff8800382d8000
>> > ffff8800382d8220
>> > [   77.302906] Call Trace:
>> > [   77.303246]  [<ffffffff8238ba79>] dump_stack+0x4d/0x66
>> > [   77.303928]  [<ffffffff820bd52b>] addrconf_join_solict+0x4b/0xb0
>> > [   77.304731]  [<ffffffff820b031b>] ipv6_dev_ac_inc+0x2bb/0x330
>> > [   77.305498]  [<ffffffff820b0060>] ? ac6_seq_start+0x260/0x260
>> > [   77.306257]  [<ffffffff820b05fe>] ipv6_sock_ac_join+0x26e/0x360
>> > [   77.307046]  [<ffffffff820b0429>] ? ipv6_sock_ac_join+0x99/0x360
>> > [   77.307798]  [<ffffffff820cdd60>] do_ipv6_setsockopt.isra.5+0xa70/0xf20
>>
>>
>> I think we should just use rtnl_lock() instead of rcu_read_lock() there,
>> it is not a hot path worth optimization.
>>
>> Please try the attached patch.
>
> note: it doesn't build as it is now, it needs:
>
> -EXPORT_SYMBOL(dev_get_by_flags_rcu);
> +EXPORT_SYMBOL(dev_get_by_flags);
>
>
> I just tried your patch with a basic test program (open
> socket/join/leave/close and open socket/join/close).
>
> I think you need to modify ipv6_sock_ac_close as well, or you can still
> trigger the assertion when closing the socket without leaving first.

You are absolutely right here.

Can I have your Signed-off-by and Tested-by before sending the patch
formally?

Thanks!
