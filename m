From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Tue, 28 Feb 2017 22:25:28 -0500 (EST)
Message-ID: <20170228.222528.1290209338537176135.davem@davemloft.net>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
        <CAHO5Pa1QdQTyEFVAc_E+y3GkYhXM2=z6UXSeoH79ybFiBxs7ag@mail.gmail.com>
        <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, willemdebruijn.kernel@gmail.com,
        netdev@vger.kernel.org, willemb@google.com,
        linux-api@vger.kernel.org
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751823AbdCADZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 22:25:57 -0500
In-Reply-To: <CALCETrU3tohXaoOTMi8J4FdTggGhvauHt12KyLFV=Q0FjiDNbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 28 Feb 2017 11:46:23 -0800

> On Mon, Feb 27, 2017 at 10:57 AM, Michael Kerrisk
> <mtk.manpages@gmail.com> wrote:
>> [CC += linux-api@vger.kernel.org]
>>
>> Hi Willem
>>
> 
>>> On a send call with MSG_ZEROCOPY, the kernel pins the user pages and
>>> creates skbuff fragments directly from these pages. On tx completion,
>>> it notifies the socket owner that it is safe to modify memory by
>>> queuing a completion notification onto the socket error queue.
> 
> What happens if the user writes to the pages while it's not safe?

Just want to mention that this ability to write to data behind a
network send's back is not a new thing added by MSG_ZEROCOPY.

All of this is already possible with sendfile().  The pages can be
written to completely asynchronously to the data being pulled out of
the page cache into the transmit path.

The crypto case is interesting, but that is a seperate discussion
about an existing problem rather than something specifically new to
the MSG_ZEROCOPY changes.

Thanks.
