From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-next: net->netns_ids is used after calling idr_destroy for it
Date: Wed, 16 Nov 2016 10:04:03 -0800
Message-ID: <CAM_iQpVG1gHvzvL0X8zAuFzjNTJHzRVUzO_m6UEo6tGWNP7qjw@mail.gmail.com>
References: <CANaxB-x7FgxpAwpa-RgOvUptrCRUmAE6NFm3As+LuXUE=fHJyA@mail.gmail.com>
 <CAM_iQpUQOCsVkaRPU3OkmNvyOLDtmRRK1G3uzvi9URSVEbapJQ@mail.gmail.com>
 <CAM_iQpU=DXKEboYHi4yO3m6VuUm1RoDRD26ZK-pVY--yUE0wNA@mail.gmail.com>
 <CANaxB-ysMU+QG=warwiQdC5pfXRjrSY7WOqJk0fcj-UMpipSZQ@mail.gmail.com>
 <CAM_iQpXYvGnaf=AAD5EJYqQ7WApjRyUResN+0Z_Bq1Xt8G8zQQ@mail.gmail.com>
 <CANaxB-y0_veL0hfdskXrix66FzydTSQ=MXOkmw72RsFqcXj9Pw@mail.gmail.com> <CANaxB-ypW4cFxNTAaS-n6ehNHxGyxe9x0G8SJap6PBp8UJX9gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andrei Vagin <avagin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f170.google.com ([209.85.213.170]:35009 "EHLO
        mail-yb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932155AbcKPSEY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:04:24 -0500
Received: by mail-yb0-f170.google.com with SMTP id d128so45308237ybh.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 10:04:24 -0800 (PST)
In-Reply-To: <CANaxB-ypW4cFxNTAaS-n6ehNHxGyxe9x0G8SJap6PBp8UJX9gA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 2:45 PM, Andrei Vagin <avagin@gmail.com> wrote:
> On Tue, Nov 15, 2016 at 2:21 PM, Andrei Vagin <avagin@gmail.com> wrote:
>> I would like to agree with you here, but looks like sockets with
>> NETLINK_F_LISTEN_ALL_NSID are able to catch these messages.
>
> Actually I found that I was wrong.
>
> do_one_broadcast() sends a notification only if a device network
> namespace has an id in a socket netns. But cleanup_net() removes all
> id-s to a target namespace, so just ignore my last comment.

The point is all sockets in that netns are already gone at that point
because of refcount.

cleanup_net() also destroys net->netns_ids, so it should not be even
accessed after that point.
