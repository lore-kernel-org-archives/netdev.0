From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Tue, 20 Dec 2016 11:31:38 -0800
Message-ID: <CAM_iQpUgqJEG544HqH1iwdQFL9-nV3-hMuuH_eU9OnJ--pX+jg@mail.gmail.com>
References: <20161219.144848.736886978545428136.davem@davemloft.net>
 <20161220003144.omoqyghgdfbxdyuu@codemonkey.org.uk> <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
 <20161219.203623.119653805184192345.davem@davemloft.net> <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34256 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936617AbcLTTcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 14:32:00 -0500
Received: by mail-qt0-f195.google.com with SMTP id p16so954889qta.1
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 11:31:59 -0800 (PST)
In-Reply-To: <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2016 at 10:17 AM, Dave Jones <davej@codemonkey.org.uk> wrote:
> On Mon, Dec 19, 2016 at 08:36:23PM -0500, David Miller wrote:
>  > From: Dave Jones <davej@codemonkey.org.uk>
>  > Date: Mon, 19 Dec 2016 19:40:13 -0500
>  >
>  > > On Mon, Dec 19, 2016 at 07:31:44PM -0500, Dave Jones wrote:
>  > >
>  > >  > Unfortunately, this made no difference.  I spent some time today trying
>  > >  > to make a better reproducer, but failed. I'll revisit again tomorrow.
>  > >  >
>  > >  > Maybe I need >1 process/thread to trigger this.  That would explain why
>  > >  > I can trigger it with Trinity.
>  > >
>  > > scratch that last part, I finally just repro'd it with a single process.
>  >
>  > Thanks for the info, I'll try to think about this some more.
>
> I threw in some debug printks right before that BUG_ON.
> it's always this:
>
> skb->len=31 skb->data_len=0 offset:30 total_len:9

Clearly we fail because 30 > 31 - 2, seems 'offset' is not correct here,
off-by-one?
