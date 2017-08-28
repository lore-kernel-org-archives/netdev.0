From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: mlxsw and rtnl lock
Date: Mon, 28 Aug 2017 08:55:56 -0700
Message-ID: <CAJieiUjvERvBFZ9qaSPLrVj=V3XivsiRGDpOsHqbKdwS-+xJeQ@mail.gmail.com>
References: <dccefbeb-b5c3-14ed-05d3-07d464989708@gmail.com> <20170826170418.GA22324@shredder>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Ahern <dsahern@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mlxsw <mlxsw@mellanox.com>
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:36023 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdH1Pz5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 11:55:57 -0400
Received: by mail-vk0-f45.google.com with SMTP id d124so2545016vkf.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 08:55:57 -0700 (PDT)
In-Reply-To: <20170826170418.GA22324@shredder>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 26, 2017 at 10:04 AM, Ido Schimmel <idosch@idosch.org> wrote:
> On Fri, Aug 25, 2017 at 01:26:07PM -0700, David Ahern wrote:
>> Jiri / Ido:
>>
>>
[snip]
>
> Regarding the silent abort, that's intentional. You can look at the same
> code in v4.9 - when the chain was still blocking - and you'll see that
> we didn't propagate the error even then. This was discussed in the past
> and the conclusion was that user doesn't expect to operation to fail. If
> hardware resources are exceeded, we let the kernel take care of the
> forwarding instead.

History here is that the initial fib offload hooks were added during
rocker days.
subsequently we have had many discussions (on offload policies) to see
if we can remove that
check and report the error back to the user (routing daemon in this
case) since the cpu kernel
cannot handle 100G or more traffic on such platforms. Basically the
cpu kernel cannot take care
of forwarding for such platforms. I believe this came up during the
last switchdev BOF as well.
The current silent abort is in there because kernel needs to maintain
its semantics for hardware offload.
Which is a valid position but we will need to find a way to make it
work for switch platforms.

IIUC, the only place where switchdev offload returns error to the user is
'bridge and bond membership offload'

I know fib and bridge fdb offload don't propagate errors to the user
(maybe they used to before moving to notifiers ?. need to check
history on this).

Are tc hardware offload errors propagated to the user ?

It is a bit inconsistent today, some errors are propagated to the user
and some are not.
