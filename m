From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: mlxsw and rtnl lock
Date: Tue, 29 Aug 2017 22:16:10 +0300
Message-ID: <32962969-5999-e475-75f1-6ac7e5d76f1b@mellanox.com>
References: <dccefbeb-b5c3-14ed-05d3-07d464989708@gmail.com>
 <20170826170418.GA22324@shredder>
 <b6dc0a4e-4ed9-ed5f-ac0f-c3fe06d5ed68@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mlxsw@mellanox.com
To: David Ahern <dsahern@gmail.com>, Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20053.outbound.protection.outlook.com ([40.107.2.53]:53674
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751215AbdH2TQS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 15:16:18 -0400
In-Reply-To: <b6dc0a4e-4ed9-ed5f-ac0f-c3fe06d5ed68@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/28/2017 09:00 PM, David Ahern wrote:
> On 8/26/17 11:04 AM, Ido Schimmel wrote:
>> Regarding the silent abort, that's intentional. You can look at the same
>> code in v4.9 - when the chain was still blocking - and you'll see that
>> we didn't propagate the error even then. This was discussed in the past
>> and the conclusion was that user doesn't expect to operation to fail. If
>> hardware resources are exceeded, we let the kernel take care of the
>> forwarding instead.
>>
> 
> In addition to Roopa's comments... The silent abort is not a good user
> experience. Right now it's add a network address or route, cross fingers
> and hope it does not overflow some limit (nexthop, ecmp, neighbor,
> prefix, etc) that triggers the offload abort.
> 
> The mlxsw driver queries for some limits (e.g., max rifs) but I don't
> see any query related to current usage, and there is no API to pass any
> of that data to user space so user space has no programmatic way to
> handle this. I realize you are aware of this limitation. The point is to

The first dpipe table that was introduced was the erif table.
which gathers L3 statistics.

The rifs are actually also fixed size resource, so maybe it is
more correct to introduce it as 'resources' and connect it to
the erif table. That way you will be able to obtain current
usage, and receive notification when it will be drained out.

> emphasize the need to resolve this.
> 
