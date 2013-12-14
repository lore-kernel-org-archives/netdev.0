From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: bnx2x_sriov.c: Missing switch/case breaks?
Date: Sat, 14 Dec 2013 06:16:46 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF1A735@SJEXCHMB10.corp.ad.broadcom.com>
References: <1386975703.2479.48.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:61824 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab3LNGQs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 01:16:48 -0500
In-Reply-To: <1386975703.2479.48.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Ariel.
> 
> I wrote a little checkpatch script to look for missing
> switch/case breaks.
> 
> http://www.kernelhub.org/?msg=379933&p=2
> 
> There are _many_ instances of case blocks in sriov.c
> that could be missing breaks as they use fall-throughs.
> 
> It would be good if these are actually intended to be
> fall-throughs to add a /* fall-through */ comment between
> each case block.
> 
> For instance:
> 
> static void bnx2x_vfop_qctor(struct bnx2x *bp, struct bnx2x_virtf *vf)
> {
> [...]
> 	switch (state) {
> 	case BNX2X_VFOP_QCTOR_INIT:
> 
> 		/* has this queue already been opened? */
> 		if (bnx2x_get_q_logical_state(bp, q_params->q_obj) ==
> 		    BNX2X_Q_LOGICAL_STATE_ACTIVE) {
> 			DP(BNX2X_MSG_IOV,
> 			   "Entered qctor but queue was already up. Aborting
> gracefully\n");
> 			goto op_done;
> 		}
> 
> 		/* next state */
> 		vfop->state = BNX2X_VFOP_QCTOR_SETUP;
> 
> 		q_params->cmd = BNX2X_Q_CMD_INIT;
> 		vfop->rc = bnx2x_queue_state_change(bp, q_params);
> 
> 		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT); 

Hi Joe,

The `vfop' part of the code contains a lot of usage of the `bnx2x_vfop_finalize()',
which either goto or return at the end of almost every case.
"Normal" analysis tools/scripts fail to recognize them as  valid case breaks.

Adding `fallthrough' comments would make little sense, as this is not the real
behavior; Perhaps we need some alternative comment? (something in the line
of `macro case break')

Cheers,
Yuval
