From: Joe Perches <joe@perches.com>
Subject: bnx2x_sriov.c: Missing switch/case breaks?
Date: Fri, 13 Dec 2013 15:01:43 -0800
Message-ID: <1386975703.2479.48.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Ariel Elior <ariele@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ariel.

I wrote a little checkpatch script to look for missing
switch/case breaks.

http://www.kernelhub.org/?msg=379933&p=2

There are _many_ instances of case blocks in sriov.c
that could be missing breaks as they use fall-throughs.

It would be good if these are actually intended to be
fall-throughs to add a /* fall-through */ comment between
each case block.

For instance:

static void bnx2x_vfop_qctor(struct bnx2x *bp, struct bnx2x_virtf *vf)
{
[...]
	switch (state) {
	case BNX2X_VFOP_QCTOR_INIT:

		/* has this queue already been opened? */
		if (bnx2x_get_q_logical_state(bp, q_params->q_obj) ==
		    BNX2X_Q_LOGICAL_STATE_ACTIVE) {
			DP(BNX2X_MSG_IOV,
			   "Entered qctor but queue was already up. Aborting gracefully\n");
			goto op_done;
		}

		/* next state */
		vfop->state = BNX2X_VFOP_QCTOR_SETUP;

		q_params->cmd = BNX2X_Q_CMD_INIT;
		vfop->rc = bnx2x_queue_state_change(bp, q_params);

		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);

	case BNX2X_VFOP_QCTOR_SETUP:
		/* next state */
		vfop->state = BNX2X_VFOP_QCTOR_INT_EN;

		/* copy pre-prepared setup params to the queue-state params */
		vfop->op_p->qctor.qstate.params.setup =
			vfop->op_p->qctor.prep_qsetup;

		q_params->cmd = BNX2X_Q_CMD_SETUP;
		vfop->rc = bnx2x_queue_state_change(bp, q_params);

		bnx2x_vfop_finalize(vf, vfop->rc, VFOP_CONT);

---

Here's the checkpatch output on that file

$ ./scripts/checkpatch.pl -f --types=missing_break drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#326: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:326:
+	case BNX2X_VFOP_QCTOR_SETUP:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#339: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:339:
+	case BNX2X_VFOP_QCTOR_INT_EN:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#416: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:416:
+	case BNX2X_VFOP_QDTOR_TERMINATE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#425: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:425:
+	case BNX2X_VFOP_QDTOR_CFCDEL:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#437: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:437:
+	case BNX2X_VFOP_QDTOR_DONE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#622: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:622:
+	case BNX2X_VFOP_VLAN_MAC_CONFIG_SINGLE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#633: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:633:
+	case BNX2X_VFOP_VLAN_MAC_CHK_DONE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#637: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:637:
+	case BNX2X_VFOP_MAC_CONFIG_LIST:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#650: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:650:
+	case BNX2X_VFOP_VLAN_CONFIG_LIST:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#662: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:662:
+	default:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#971: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:971:
+	case BNX2X_VFOP_QSETUP_DONE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#1068: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:1068:
+	case BNX2X_VFOP_QFLR_DONE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#1119: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:1119:
+	case BNX2X_VFOP_MCAST_ADD:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#1136: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:1136:
+	case BNX2X_VFOP_MCAST_CHK_DONE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#1139: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:1139:
+	default:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#1217: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:1217:
+	case BNX2X_VFOP_RXMODE_DONE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#1326: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:1326:
+	case BNX2X_VFOP_QTEARDOWN_DONE:

WARNING: Possible switch case/default not preceeded by break or fallthrough comment
#2985: FILE: drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:2985:
+	case BNX2X_VFOP_RSS_DONE:

total: 0 errors, 18 warnings, 3683 lines checked

NOTE: Used message types: MISSING_BREAK

drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c has style problems, please review.

If any of these errors are false positives, please report
them to the maintainer, see CHECKPATCH in MAINTAINERS.
total: 0 errors, 0 warnings, 2006 lines checked

NOTE: Used message types: MISSING_BREAK
