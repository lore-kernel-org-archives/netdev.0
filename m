From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2/3] net/bonding: Return nothing for not applicable values
Date: Wed, 28 Nov 2007 17:13:15 -0800
Message-ID: <26966.1196298795@death>
References: <87wss3jin5.fsf@szonett.ki.iif.hu>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3Futf-8=3Fq=3FFerenc=5FW=3DC3=3DA1gner=3F=3D?=
	<wferi@niif.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762643AbXK2BNo@vger.kernel.org>
In-reply-to: <87wss3jin5.fsf@szonett.ki.iif.hu> 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>The previous code returned '\n' (that is, a single empty line)
>from most files, with one exception (xmit_hash_policy), where
>it returned 'NA\n'.  This patch consolidates each file to return
>nothing at all if not applicable, not even a '\n'.
>
>I find this behaviour more usual, more useful, more efficient
>and shorter to code from both sides.
[...]
>+	if ((bond->params.mode == BOND_MODE_XOR) ||
>+	    (bond->params.mode == BOND_MODE_8023AD)) {
> 		count = sprintf(buf, "%s %d\n",
> 			xmit_hashtype_tbl[bond->params.xmit_policy].modename,
> 			bond->params.xmit_policy);

	Rather than this (returning nothing if not in xor or 802.3ad
mode), I'd prefer to see this always return whatever the xmit policy is
(regardless of the mode), and remove the mode test from
bonding_store_xmit_hash().

	This would be consistent with the way the arp_ip_target option
is treated: the actual value is always displayed, even if it is not
used, and it is legal to change the value, regardless of the mode.

	Other than this, I'm fine with the changes.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
