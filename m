From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] net/core: Add VF link state control policy
Date: Wed, 11 Jun 2014 11:01:10 +0300
Message-ID: <53980CC6.1080303@mellanox.com>
References: <d040256cbe494908726bb1d05612f69cee4ff040.1402430365.git.dledford@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rony Efraim <ronye@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Doug Ledford <dledford@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog124.obsmtp.com ([207.126.144.157]:34808 "EHLO
	eu1sys200aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754058AbaFKICK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 04:02:10 -0400
In-Reply-To: <d040256cbe494908726bb1d05612f69cee4ff040.1402430365.git.dledford@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2014 22:59, Doug Ledford wrote:
> Commit 1d8faf48c7 added VF link state control to the netlink VF nested
> structure, but failed to add a proper entry for the new structure into
> the VF policy table.  Add the missing entry so the table and the actual
> data copied into the netlink nested struct are in sync.
>
> Signed-off-by: Doug Ledford <dledford@redhat.com>
> ---
>   net/core/rtnetlink.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 2d8d8fcfa06..cdccf028171 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1208,6 +1208,8 @@ static const struct nla_policy ifla_vf_policy[IFLA_VF_MAX+1] = {
>   				    .len = sizeof(struct ifla_vf_tx_rate) },
>   	[IFLA_VF_SPOOFCHK]	= { .type = NLA_BINARY,
>   				    .len = sizeof(struct ifla_vf_spoofchk) },
> +	[IFLA_VF_LINK_STATE]	= { .type = NLA_BINARY,
> +				    .len = sizeof(struct ifla_vf_link_state) },
>   };

nice catch, thanks. Note that currently this table isn't in use, so 
fixing here would  actually serve to avoid future bugs, but this is of 
course OK too.

Rony and Or.
