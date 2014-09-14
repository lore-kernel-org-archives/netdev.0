From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [Bridge] [PATCH 3/3] bridge; Automatically filter vlans configured
 on top of bridge
Date: Mon, 15 Sep 2014 00:39:46 +0900
Message-ID: <5415B6C2.5030702@gmail.com>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com> <1410554691-18467-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:53446 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbaINPjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2014 11:39:53 -0400
Received: by mail-pd0-f172.google.com with SMTP id v10so4593535pde.17
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 08:39:52 -0700 (PDT)
In-Reply-To: <1410554691-18467-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(14/09/13 (土) 5:44), Vladislav Yasevich wrote:
> If the user configures vlan devices on top of the bridge,
> automatically set up filter entries for it as long as
> bridge vlan protocol matches that of the vlan.
> This allows the user to atomatically receive vlan traffic
> for the vlans that are convifgured.

Changing br->vlan_proto seems to cause inconsistency between vlan
interfaces and filter settings.
Can we automatically change filters when setting vlan_proto?

>
...
> +static int br_vlan_rx_kill_vid(struct net_device *br_dev,
> +			       __be16 proto, u16 vid)
...
> +	/* Don't report error.  This will fail if the vlan was
> +	 * previousely remove by some other means and we don't
> +	 * wan't to polute the log/bug the user.
> +	 */
> +	br_vlan_delete(br, vid);
> +	return 0;
> +}

It might lead to unexpected behaviour, for example,
1. create br0.10
2. set pvid to 10 on br0
3. delete br0.10
Then, pvid will also be cleared?
Something like ref counting is needed?

Thanks,
Toshiaki Makita
