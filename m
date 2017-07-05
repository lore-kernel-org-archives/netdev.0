From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] tcp: reset sk_rx_dst in tcp_disconnect()
Date: Wed, 5 Jul 2017 09:40:36 -0700
Message-ID: <CAM_iQpVGd3f=rFU5hg2+5um0eE5EP3tNUDxfy631Pxp1O9c0bw@mail.gmail.com>
References: <1498373430-24807-1-git-send-email-xiyou.wangcong@gmail.com> <CAAvyFNitoxhPpivWaY+qgW+ssVxvt-3O+4eBfYCN81a0Dn7JZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Wagin <avagin@gmail.com>, Kaiwen Xu <kaiwen.xu@hulu.com>
To: Jamie Bainbridge <jamie.bainbridge@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33628 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751756AbdGEQk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 12:40:57 -0400
Received: by mail-wm0-f65.google.com with SMTP id j85so33645669wmj.0
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 09:40:57 -0700 (PDT)
In-Reply-To: <CAAvyFNitoxhPpivWaY+qgW+ssVxvt-3O+4eBfYCN81a0Dn7JZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 4, 2017 at 11:54 PM, Jamie Bainbridge
<jamie.bainbridge@gmail.com> wrote:
> On 25 June 2017 at 16:50, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> We have to reset the sk->sk_rx_dst when we disconnect a TCP
>> connection, because otherwise when we re-connect it this
>> dst reference is simply overridden in tcp_finish_connect().
>>
>> This fixes a dst leak which leads to a loopback dev refcnt
>> leak. It is a long-standing bug, Kevin reported a very similar
>> (if not same) bug before. Thanks to Andrei for providing such
>> a reliable reproducer which greatly narrows down the problem.
>>
>> Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")
>> Reported-by: Andrei Vagin <avagin@gmail.com>
>> Reported-by: Kevin Xu <kaiwen.xu@hulu.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> Are you able to supply the reproducer for this?
>
> I did search for a previous thread about it but could not find.

Here it is:
http://marc.info/?l=linux-kernel&m=149825461307610&w=2
