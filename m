From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] mac80211_hwsim: Allow managing radios from
 non-initial namespaces
Date: Thu, 5 May 2016 10:16:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4B5302@AcuExch.aculab.com>
References: <1462258398-6749-1-git-send-email-martin@strongswan.org>
 <1462258398-6749-3-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Martin Willi' <martin@strongswan.org>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:55303 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756283AbcEEKRL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 06:17:11 -0400
In-Reply-To: <1462258398-6749-3-git-send-email-martin@strongswan.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Willi
> Sent: 03 May 2016 07:53
> While wiphys can be moved into network namespaces over nl80211, the
> creation and removal of hwsim radios is currently limited to the initial
> namespace. This patch allows management of namespaced radios from the
> owning namespace by setting genetlink netnsok.
> 
> To prevent two arbitrary namespaces from communicating over the simulated
> shared medium, radios are separated by netgroups. Each radio created in
> the same namespace lives in the same netgroup and hence can communicate
> with other radios in that group. When moving radios to other namespaces,
> the netgroup is preserved, so two radios having the same netgroup can
> communicate even if not in the same namespace; This allows a controlling
> namespace to create radios and move them to other namespaces for
> communication.
> 
...
> +	data->netgroup = *(int *)net_generic(net, hwsim_net_id);

Anything doing *(integer_type *) rings alarm bells.

I suspect you should be defining a structure that currently contains
one integer member.
Something (maybe a compile time assert) needs to check that buffer
space you are accessing (where ever it is) is large enough.

	David
