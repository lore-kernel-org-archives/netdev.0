From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [PATCH net 0/6] rtnetlink: a bunch of fixes for userspace
 notifications in changing dev properties
Date: Tue, 24 Oct 2017 22:44:19 +0200
Message-ID: <20171024224419.5f85ea71@elisabeth>
References: <cover.1508062280.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        David Ahern <dsahern@gmail.com>, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45268 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750897AbdJXUoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 16:44:25 -0400
In-Reply-To: <cover.1508062280.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Oct 2017 18:13:40 +0800
Xin Long <lucien.xin@gmail.com> wrote:

> Whenever any property of a link, address, route, etc. changes by whatever way,
> kernel should notify the programs that listen for such events in userspace.
> 
> The patchet "rtnetlink: Cleanup user notifications for netdev events" tried to
> fix a redundant notifications issue, but it also introduced a side effect.
> 
> After that, user notifications could only be sent when changing dev properties
> via netlink api. As it removed some events process in rtnetlink_event where
> the notifications was sent to users.
> 
> It resulted in no notification generated when dev properties are changed via
> other ways, like ioctl, sysfs, etc. It may cause some user programs doesn't
> work as expected because of the missing notifications.
> 
> This patchset will fix it by bringing some of these netdev events back and
> also fix the old redundant notifications issue with a proper way.
> 
> Xin Long (6):
>   rtnetlink: bring NETDEV_CHANGEMTU event process back in
>     rtnetlink_event
>   rtnetlink: bring NETDEV_CHANGE_TX_QUEUE_LEN event process back in
>     rtnetlink_event
>   rtnetlink: bring NETDEV_POST_TYPE_CHANGE event process back in
>     rtnetlink_event
>   rtnetlink: bring NETDEV_CHANGEUPPER event process back in
>     rtnetlink_event
>   rtnetlink: check DO_SETLINK_NOTIFY correctly in do_setlink
>   rtnetlink: do not set notification for tx_queue_len in do_setlink

I guess this should be considered for -stable (back to 4.12), as it
fixes quite a few critical issues in notification behaviours userspace
might rely on.

-- 
Stefano
