From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCHv2 net 2/3] openvswitch: Treat IP_CT_RELATED as new
Date: Sat, 17 Oct 2015 09:52:33 +0200
Message-ID: <20151017075233.GC13981@pox.localdomain>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
 <1445018901-18839-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35467 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbbJQHwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 03:52:36 -0400
Received: by wicll6 with SMTP id ll6so36032064wic.0
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 00:52:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445018901-18839-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/15 at 11:08am, Joe Stringer wrote:
> New, related connections are marked as such as part of ovs_ct_lookup(),
> but they are not marked as "new" if the commit flag is used. Make this
> consistent by treating IP_CT_RELATED as new as well.
> 
> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> v2: Acked.
> ---
>  net/openvswitch/conntrack.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 80bf702715bb..480dbb9095b7 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -86,6 +86,8 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
>  		ct_state |= OVS_CS_F_ESTABLISHED;
>  		break;
>  	case IP_CT_RELATED:
> +		ct_state |= OVS_CS_F_NEW;
> +		/* Fall through */
>  	case IP_CT_RELATED_REPLY:
>  		ct_state |= OVS_CS_F_RELATED;
>  		break;

I'm probably missing something obvious. Why is the reply direction
not considered NEW? Wouldn't this consider an ICMPv6 as related+new
depending on simply the direction?
