From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: mlxsw and rtnl lock
Date: Tue, 29 Aug 2017 09:10:25 +0300
Message-ID: <2723f732-b337-a792-05ee-4a1461bf2aad@mellanox.com>
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
Received: from mail-he1eur01on0056.outbound.protection.outlook.com ([104.47.0.56]:17476
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751066AbdH2GKe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 02:10:34 -0400
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
> emphasize the need to resolve this.
> 

We actually thought about providing he user some tools to understand
the ASIC's limitations by introducing the 'resource' object to devlink.

By linking dpipe tables to resources the user can understand which
hardware processes share a common resource, furthermore this resources
usage could be observed. By this more visibility can be obtained.

Its not a remedy for the silent abort, but, maybe a notification
can be sent from devlink in case of abort that some resources is
full.

This proposition was sent as RFC several weeks ago.
