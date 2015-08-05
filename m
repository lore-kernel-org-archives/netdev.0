From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/4] batman-adv: fix kernel crash due to missing NULL
 checks
Date: Wed, 5 Aug 2015 13:15:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB737B7@AcuExch.aculab.com>
References: <1438779107-12665-1-git-send-email-antonio@meshcoding.com>
 <1438779107-12665-3-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"b.a.t.m.a.n@lists.open-mesh.org" <b.a.t.m.a.n@lists.open-mesh.org>,
	"Marek Lindner" <mareklindner@neomailbox.ch>
To: 'Antonio Quartulli' <antonio@meshcoding.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:62284 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbbHENRO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 09:17:14 -0400
In-Reply-To: <1438779107-12665-3-git-send-email-antonio@meshcoding.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Antonio Quartulli
> Sent: 05 August 2015 13:52
> From: Marek Lindner <mareklindner@neomailbox.ch>
> 
> batadv_softif_vlan_get() may return NULL which has to be verified
> by the caller.
> 
...
> diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
> index c002961..a2fc843 100644
> --- a/net/batman-adv/soft-interface.c
> +++ b/net/batman-adv/soft-interface.c
> @@ -479,6 +479,9 @@ out:
>   */
>  void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *vlan)
>  {
> +	if (!vlan)
> +		return;
> +

This bit doesn't look necessary.
You've added checks to some callers, the others probably don't need the check.

> @@ -1066,6 +1069,9 @@ uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
> 
>  	/* decrease the reference held for this vlan */
>  	vlan = batadv_softif_vlan_get(bat_priv, vid);
> +	if (!vlan)
> +		goto out;
> +
>  	batadv_softif_vlan_free_ref(vlan);
>  	batadv_softif_vlan_free_ref(vlan);

That code is ringing alarm bells.
If you expect to have a reference count the object better exist.
If you can remove a reference count from a 'random' object then
you can break the reference counting of objects.

So is this test just hiding anoter bug somewhere??

	David
