From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/4] bonding: Handle notifications during
 work-queue processing gracefully
Date: Sun, 22 Mar 2015 20:53:27 +0300
Message-ID: <550F0197.70800@cogentembedded.com>
References: <1426916361-18328-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:36759 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbbCVRxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:53:30 -0400
Received: by labe2 with SMTP id e2so43508499lab.3
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:53:29 -0700 (PDT)
In-Reply-To: <1426916361-18328-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/21/2015 8:39 AM, Mahesh Bandewar wrote:

> RTNL is required for sending notifications and if rtnl can not be
> acquired, current code skips sending notification. This is especially
> bad if the monitoring values selected are large.

> This patch adds a bitmask and uses a bit per such work-queue and attempts
> to reschedule the work (aggressively) until notifications are sent out and
> then resumes the regular cycle.

> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
>   include/net/bonding.h | 19 +++++++++++++++++++
>   1 file changed, 19 insertions(+)

> diff --git a/include/net/bonding.h b/include/net/bonding.h
> index 0ac45b4f7f2a..fede3ab4bbcf 100644
> --- a/include/net/bonding.h
> +++ b/include/net/bonding.h
[...]
> @@ -259,6 +260,24 @@ struct bond_vlan_tag {
>   	unsigned short	vlan_id;
>   };
>
> +typedef enum {
> +	BOND_MII_NOTIF = 0,
> +	BOND_ARP_NOTIF,
> +	BOND_AD_NOTIF,
> +} bond_notif_pending_t;
> +
> +static inline bool bond_get_notif_pending(struct bonding *bond,
> +					  bond_notif_pending_t bit)
> +{
> +	return !!test_and_clear_bit(bit, &bond->notif_work_mask);
> +}
> +
> +static inline void bond_set_notif_pending(struct bonding *bond,
> +					  bond_notif_pending_t bit)
> +{
> +		set_bit(bit, &bond->notif_work_mask);

    One tab to many here. :-)

> +}
> +
>   /**
>    * Returns NULL if the net_device does not belong to any of the bond's slaves
>    *

WBR, Sergei
