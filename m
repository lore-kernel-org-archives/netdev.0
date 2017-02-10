From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/7] mlxsw: Identical routes handling
Date: Fri, 10 Feb 2017 11:34:44 -0500 (EST)
Message-ID: <20170210.113444.1607640729939984965.davem@davemloft.net>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41756 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751985AbdBJQlc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 11:41:32 -0500
In-Reply-To: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  9 Feb 2017 10:28:37 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> The kernel can store several FIB aliases that share the same prefix and
> length. These aliases can differ in other parameters such as TOS and
> metric, which are taken into account during lookup.
> 
> Offloading devices might not have the same flexibility, allowing only a
> single route with the same prefix and length to be reflected. mlxsw is
> one such device.
> 
> This patchset aims to correctly handle this situation in the mlxsw
> driver. The first four patches introduce small changes in the IPv4 FIB
> code, so that listeners of the FIB notification chain will be able to
> correctly handle identical routes.
> 
> The last three patches build on top of previous work and introduce the
> necessary changes in the mlxsw driver. The biggest change is the
> introduction of a FIB node, where identical routes are chained, instead
> of a primitive reference counting. This is explained in detail in the
> fifth patch.

Looks good, series applied, thanks Jiri and Ido.

I think you took care of this properly, but just always make sure that
if a delete event is emitted the object is not in the table any longer
and cannot be discovered by a parallel thread of execution at that
point.

Likewise a good rule of thumb is to make sure the object is
discoverable when you emit the add event.

Thanks again.
