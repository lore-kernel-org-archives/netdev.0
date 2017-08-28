From: David Ahern <dsahern@gmail.com>
Subject: Re: mlxsw and rtnl lock
Date: Mon, 28 Aug 2017 12:00:39 -0600
Message-ID: <b6dc0a4e-4ed9-ed5f-ac0f-c3fe06d5ed68@gmail.com>
References: <dccefbeb-b5c3-14ed-05d3-07d464989708@gmail.com>
 <20170826170418.GA22324@shredder>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mlxsw@mellanox.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34443 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdH1SAl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:00:41 -0400
Received: by mail-pf0-f178.google.com with SMTP id h75so3313983pfh.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 11:00:41 -0700 (PDT)
In-Reply-To: <20170826170418.GA22324@shredder>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/26/17 11:04 AM, Ido Schimmel wrote:
> Regarding the silent abort, that's intentional. You can look at the same
> code in v4.9 - when the chain was still blocking - and you'll see that
> we didn't propagate the error even then. This was discussed in the past
> and the conclusion was that user doesn't expect to operation to fail. If
> hardware resources are exceeded, we let the kernel take care of the
> forwarding instead.
> 

In addition to Roopa's comments... The silent abort is not a good user
experience. Right now it's add a network address or route, cross fingers
and hope it does not overflow some limit (nexthop, ecmp, neighbor,
prefix, etc) that triggers the offload abort.

The mlxsw driver queries for some limits (e.g., max rifs) but I don't
see any query related to current usage, and there is no API to pass any
of that data to user space so user space has no programmatic way to
handle this. I realize you are aware of this limitation. The point is to
emphasize the need to resolve this.
