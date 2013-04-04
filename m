From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 3/3] net/mlx4_en: Enable open-lldp DCB support
Date: Thu, 04 Apr 2013 12:01:06 -0700
Message-ID: <515DCDF2.8070304@intel.com>
References: <1365085574-12057-1-git-send-email-ogerlitz@mellanox.com> <1365085574-12057-4-git-send-email-ogerlitz@mellanox.com> <515DA342.5020503@intel.com> <515DA579.3050006@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	netdev@vger.kernel.org, amirv@mellanox.com
To: Sagi Grimberg <sagig@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27757 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763581Ab3DDTBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 15:01:08 -0400
In-Reply-To: <515DA579.3050006@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2013 9:08 AM, Sagi Grimberg wrote:
> On 4/4/2013 6:58 PM, John Fastabend wrote:
>> On 4/4/2013 7:26 AM, Or Gerlitz wrote:
>>> From: Sagi Grimberg <sagig@mellanox.com>
>>>
>>> The lldpad daemon queries the driver caps via the getcaps and getstate
>>> routines. Added the prpoer dbcnl_ops entries to support that.
>>>
>>> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
>>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>>> ---
>>
>> Does lldpad work now with the mlx4_en driver?
>>
>> Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
>>
>
> Yes.
>
> -Sagi

So I looked at your code and lldpad a bit closer. I think this
just works around a bug in lldpad. Also with this patch lldpad
would try to xmit lldp pkts which would conflict with your firmware
agent right?

For IEEE DCBX modes lldpad should check the return values from
the getdcbx dcbnl_rtnl_ops which you already have filled out. I
would expect your driver to return DCB_CAP_DCBX_LLD_MANAGED to
indicate it is being managed by firmware.

See bnx2x_dcbnl_get_dcbx() for an example of an implementation
which I believe is correct. I'll fix the user space lldpad bug.

Looks like I added my reveiwed-by line too quickly.

Thanks,
.John
