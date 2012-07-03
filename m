From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH 00/10] Make XPS usable within ixgbe
Date: Tue, 03 Jul 2012 15:41:59 -0700
Message-ID: <4FF37537.20104@intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com> <CA+mtBx-ZGFUT6JcxiLcTOMteN1-DS5_eoAC5CgU7UEFup1FaqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, alexander.duyck@gmail.com
To: Tom Herbert <therbert@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45932 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756267Ab2GCWmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2012 18:42:00 -0400
In-Reply-To: <CA+mtBx-ZGFUT6JcxiLcTOMteN1-DS5_eoAC5CgU7UEFup1FaqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/3/2012 3:30 PM, Tom Herbert wrote:
> Hi Alexander,
>
> Thanks for this work!
>
> Some general comments:
>
> 1) skb_tx_hash is called from a handful of drivers (bnx2x, ixgbe,
> mlx4, and bonding).  Would it make sent to call xps_get_cpu from that
> function (unfortunately the use of ndo_select_queue is likely
> bypassing xps unnecessarily in these drivers).

I suspect we can get rid of the select_queue cases for at least
bnx2x, ixgbe, and mlx4. We might need to be a bit clever to resolve
the mlx4 case but should be doable.

Anyways I would like to see these cases refactored away.

> 2) Instead of (or maybe in addition to) allowing driver to program xps
> maps, we could parameterize get_xps_cpu to optionally include a bit
> map of acceptable queues.  This would be useful to define a
> hierarchical queue selection (like first choose a set for QoS, then
> amongst those chose one base on xps).
>

Agreed.

We likely need something like (2) to get this to work with mqprio and
other QOS schemes in use.

.John
