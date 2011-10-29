From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Logic bug in B.A.T.M.A.N. advanced driver
Date: Sat, 29 Oct 2011 20:45:43 +0200
Message-ID: <4EAC49D7.2060609@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: Marek Lindner <lindner_marek@yahoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:43761 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933900Ab1J2Spr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 14:45:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marek,

Consider this code from "net/batman-adv/bitarray.c":

int bit_get_packet(void *priv, unsigned long *seq_bits,
		    int32_t seq_num_diff, int set_mark)
{
        ...

	if ((seq_num_diff >= TQ_LOCAL_WINDOW_SIZE)
		|| (seq_num_diff < EXPECTED_SEQNO_RANGE)) {
		bat_dbg(DBG_BATMAN, bat_priv,
			"We missed a lot of packets (%i) !\n",
			seq_num_diff - 1);
		bit_reset_window(seq_bits);
		if (set_mark)
			bit_mark(seq_bits, 0);
		return 1;
	}
-----------------------------------

The defines from "main.h":
#define TQ_LOCAL_WINDOW_SIZE 64
#define EXPECTED_SEQNO_RANGE	65536


So that if() statement will translate to:

-----------------------------------
	if ((seq_num_diff >= 64)
		|| (seq_num_diff < 65536)) {
-----------------------------------

and this will always evaluate to true.

Detected by "cppcheck":
"[net/batman-adv/bitarray.c:157]: (warning) Mutual exclusion over ||
always evaluates to true. Did you intend to use && instead?"

Cheers,
Thomas
