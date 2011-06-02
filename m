From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Thu, 2 Jun 2011 15:15:18 +0200
Message-ID: <20110602131517.GE2760@psychotron.brq.redhat.com>
References: <m1aaectyed.fsf@fess.ebiederm.org>
 <20110524.022406.2228892895515155850.davem@davemloft.net>
 <m1oc2spmyt.fsf@fess.ebiederm.org>
 <20110601.205940.1179055860757569997.davem@davemloft.net>
 <m11uzcidvq.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131Ab1FBNPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2011 09:15:31 -0400
Content-Disposition: inline
In-Reply-To: <m11uzcidvq.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 02, 2011 at 03:03:53PM CEST, ebiederm@xmission.com wrote:
>
>Testing of VLAN_FLAG_REORDER_HDR does not belong in vlan_untag
>but rather in vlan_do_receive.  Otherwise the vlan header
>will not be properly put on the packet in the case of
>vlan header accelleration.
>
>As we remove the check from vlan_check_reorder_header
>rename it vlan_reorder_header to keep the naming clean.
>
>Fix up the skb->pkt_type early so we don't look at the packet
>after adding the vlan tag, which guarantees we don't goof
>and look at the wrong field.
>
>Use a simple if statement instead of a complicated switch
>statement to decided that we need to increment rx_stats
>for a multicast packet.
>
>Hopefully at somepoint we will just declare the case where
>VLAN_FLAG_REORDER_HDR is cleared as unsupported and remove
>the code.  Until then this keeps it working correctly.
>
>Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Looking good to me. Thanks Eric.

Reviewed-by: Jiri Pirko <jpirko@redhat.com>

