From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 03/10] rtnl: expose physical switch id for
 particular device
Date: Sun, 09 Nov 2014 22:43:58 -0500
Message-ID: <5460347E.6040000@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:59116 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaKJDoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:44:04 -0500
Received: by mail-ie0-f179.google.com with SMTP id rl12so8243693iec.24
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:44:03 -0800 (PST)
In-Reply-To: <1415530280-9190-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/14 05:51, Jiri Pirko wrote:
> The netdevice represents a port in a switch, it will expose
> IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with the same value
> belong to one physical switch.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/uapi/linux/if_link.h |  1 +
>   net/core/rtnetlink.c         | 26 +++++++++++++++++++++++++-
>   2 files changed, 26 insertions(+), 1 deletion(-)
>
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 7072d83..4163753 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -145,6 +145,7 @@ enum {
>   	IFLA_CARRIER,
>   	IFLA_PHYS_PORT_ID,
>   	IFLA_CARRIER_CHANGES,
> +	IFLA_PHYS_SWITCH_ID,
>   	__IFLA_MAX
>   };
>


> @@ -1198,6 +1221,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>   	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
>   	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>   	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
> +	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>   };
>

Ok, looking at this compared to #1 i can see you are introducing 
IFLA_PHYS_SWITCH_ID but then why did you need to change 
IFLA_PHYS_PORT_ID earlier?

cheers,
jamal

>   static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
>
