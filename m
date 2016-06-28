From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 08/16] net/devlink: Add E-Switch mode control
Date: Mon, 27 Jun 2016 22:57:54 -0700
Message-ID: <577211E2.90802@gmail.com>
References: <1467043649-28594-1-git-send-email-saeedm@mellanox.com>
 <1467043649-28594-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:34507 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbcF1F6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 01:58:20 -0400
Received: by mail-oi0-f41.google.com with SMTP id s66so8852053oif.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 22:58:20 -0700 (PDT)
In-Reply-To: <1467043649-28594-9-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-27 09:07 AM, Saeed Mahameed wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> 
> Add the commands to set and show the mode of SRIOV E-Switch,
> two modes are supported:
> 
> * legacy   : operating in the "old" L2 based mode (DMAC --> VF vport)
> * offloads : offloading SW rules/policy (e.g Bridge/FDB or TC/Flows based) set by the host OS
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---


Hi,

Nice work overall also I really appreciated that the core networking
interfaces appear to able to support this without any change.

On this patch though do we really need modes like this? My concern with
modes is two fold. One its another knob that some controller will have
to get right which I would prefer to avoid. And two I suspect switching
between the two modes flushes the tables or leaves them in some
unexpected state? At least I can't figure out what the expected should
be off-hand.

Could we instead continue to use the "legacy" mode by default by just
populating the fdb table correctly and then if users want to enable
the "offloads" mode they can modify the fdb tables by deleting entries
or adding them or just extending the dmac/vf mapping via 'tc'. This
would seem natural to me. The flooding rules in fdb might need to be
exposed a bit more cleanly to get the right default flooding behavior
etc. But to me at least this would be much cleaner. Everything will be
nicely defined and we wont have issues with drivers doing slightly
and subtle different defaults between legacy/offload and the transitions
between the states or on resets or etc. If users need to discover the
current configuration then they just query fdb, query tc, and the state
is known no need for any magic toggle switch as best I can see.

Otherwise I didn't review the mlx code but read the commit msgs and
it looks good. I'll take a closer look in the morning.

Thanks,
John
