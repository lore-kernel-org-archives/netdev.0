From: Daniel Axtens <dja@axtens.net>
Subject: bnx2x - bnx2x_attn_int_deasserted3 - MC assert!
Date: Thu, 18 May 2017 16:21:19 +1000
Message-ID: <87vaoyu1ls.fsf@possimpible.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36552 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753168AbdERGV0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 02:21:26 -0400
Received: by mail-pf0-f195.google.com with SMTP id n23so4567594pfb.3
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 23:21:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm looking into a powerpc 64-bit little-endian system with 4
(IBM-branded) Broadcom Corporation NetXtreme II BCM57800 1/10 Gigabit
Ethernet adaptors installed. It's running 4.11 and using Open vSwitch
and bonded interfaces. We're seeing regular firmware errors coming out
of the network cards when netperf is started as soon as the interfaces
appear:

[60072.330838] bnx2x: [bnx2x_attn_int_deasserted3:4323(enP24p1s0f0)]MC assert!
[60072.330854] bnx2x: [bnx2x_mc_assert:720(enP24p1s0f0)]XSTORM_ASSERT_LIST_INDEX 0x2
[60072.330860] bnx2x: [bnx2x_mc_assert:736(enP24p1s0f0)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43e47 0x00463e01 0x00010052
[60072.330878] bnx2x: [bnx2x_mc_assert:750(enP24p1s0f0)]Chip Revision: everest3, FW Version: 7_13_1
... (dump of values follows) ...

I've included the dmesg output with the dump of both crashing cards
below. The errors do not appear if netperf isn't started until a few
minutes after the interfaces come up. The errors are not new in 4.11 -
they have been reproduced in 4.8 and 4.10.

This all seems to come out of firmware rather than Linux, and I don't
have the datasheets to decode the magic numbers, so I was hoping you'd
be able to shed some light on it?

Thanks in advance!

Regards,
Daniel Axtens

====== dmesg output ======
[60072.330838] bnx2x: [bnx2x_attn_int_deasserted3:4323(enP24p1s0f0)]MC assert!
[60072.330854] bnx2x: [bnx2x_mc_assert:720(enP24p1s0f0)]XSTORM_ASSERT_LIST_INDEX 0x2
[60072.330860] bnx2x: [bnx2x_mc_assert:736(enP24p1s0f0)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43e47 0x00463e01 0x00010052
[60072.330878] bnx2x: [bnx2x_mc_assert:750(enP24p1s0f0)]Chip Revision: everest3, FW Version: 7_13_1
[60072.330881] bnx2x: [bnx2x_attn_int_deasserted3:4329(enP24p1s0f0)]driver assert
[60072.330884] bnx2x: [bnx2x_panic_dump:923(enP24p1s0f0)]begin crash dump -----------------
[60072.330888] bnx2x: [bnx2x_panic_dump:933(enP24p1s0f0)]def_idx(0xe51f)  def_att_idx(0x4)  attn_state(0x1)  spq_prod_idx(0x37) next_stats_cnt(0xe517)
[60072.330892] bnx2x: [bnx2x_panic_dump:938(enP24p1s0f0)]DSB: attn bits(0x0)  ack(0x1)  id(0x0)  idx(0x4)
[60072.330894] bnx2x: [bnx2x_panic_dump:939(enP24p1s0f0)]     def (0x0 0x0 0x0 0x0 0x0 0x0 0x0 0xe605 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0)  igu_sb_id(0x0)  igu_seg_id(0x1) pf_id(0x0)  vnic_id(0x0)  vf_id(0xff)  vf_valid (0x0) state(0x1)
[60072.330909] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f0)]fp0: rx_bd_prod(0x4245)  rx_bd_cons(0x7e)  rx_comp_prod(0x76e1)  rx_comp_cons(0x7515)  *rx_cons_sb(0x7515)
[60072.330913] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x287b)
[60072.330916] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp0: tx_pkt_prod(0x211b)  tx_pkt_cons(0x211b)  tx_bd_prod(0x4278)  tx_bd_cons(0x4277)  *tx_cons_sb(0x211b)
[60072.330920] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp0: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.330924] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp0: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.330928] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f0)]     run indexes (0x287b 0x0)
[60072.330929] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f0)]     indexes (0x0 0x7515 0x0 0x0 0x0 0x211b 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60072.330956] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f0)]fp1: rx_bd_prod(0x8af8)  rx_bd_cons(0x931)  rx_comp_prod(0xa811)  rx_comp_cons(0xa645)  *rx_cons_sb(0xa645)
[60072.330960] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x21d8)
[60072.330964] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp1: tx_pkt_prod(0x1eb8)  tx_pkt_cons(0x1eb8)  tx_bd_prod(0x3dad)  tx_bd_cons(0x3dac)  *tx_cons_sb(0x1eb8)
[60072.330968] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp1: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.330972] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp1: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.330975] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f0)]     run indexes (0x21d8 0x0)
[60072.330976] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f0)]     indexes (0x0 0xa645 0x0 0x0 0x0 0x1eb8 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60072.331003] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f0)]fp2: rx_bd_prod(0x1cd5)  rx_bd_cons(0xb0e)  rx_comp_prod(0xdd30)  rx_comp_cons(0xdb64)  *rx_cons_sb(0xdb64)
[60072.331007] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x97d0)
[60072.331011] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp2: tx_pkt_prod(0x1ed6)  tx_pkt_cons(0x1ed6)  tx_bd_prod(0x3de9)  tx_bd_cons(0x3de8)  *tx_cons_sb(0x1ed6)
[60072.331015] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp2: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331019] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp2: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331022] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f0)]     run indexes (0x97d0 0x0)
[60072.331023] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f0)]     indexes (0x0 0xdb64 0x0 0x0 0x0 0x1ed6 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60072.331050] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f0)]fp3: rx_bd_prod(0xea0a)  rx_bd_cons(0x843)  rx_comp_prod(0xc22b)  rx_comp_cons(0xc05f)  *rx_cons_sb(0xc05f)
[60072.331054] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x8aab)
[60072.331057] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp3: tx_pkt_prod(0x1ff3)  tx_pkt_cons(0x1ff3)  tx_bd_prod(0x41b2)  tx_bd_cons(0x41b1)  *tx_cons_sb(0x1ff3)
[60072.331062] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp3: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331065] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp3: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331069] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f0)]     run indexes (0x8aab 0x0)
[60072.331070] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f0)]     indexes (0x0 0xc05f 0x0 0x0 0x0 0x1ff3 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60072.331096] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f0)]fp4: rx_bd_prod(0xfc36)  rx_bd_cons(0xa6f)  rx_comp_prod(0x7309)  rx_comp_cons(0x713c)  *rx_cons_sb(0x713c)
[60072.331100] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x3ada)
[60072.331104] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp4: tx_pkt_prod(0x1e8a)  tx_pkt_cons(0x1e8a)  tx_bd_prod(0x3d51)  tx_bd_cons(0x3d50)  *tx_cons_sb(0x1e8a)
[60072.331108] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp4: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331112] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp4: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331115] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f0)]     run indexes (0x3ada 0x0)
[60072.331116] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f0)]     indexes (0x0 0x713c 0x0 0x0 0x0 0x1e8a 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60072.331143] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f0)]fp5: rx_bd_prod(0x4a1c)  rx_bd_cons(0x855)  rx_comp_prod(0x666e)  rx_comp_cons(0x64a2)  *rx_cons_sb(0x64a2)
[60072.331147] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0xb0dc)
[60072.331150] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp5: tx_pkt_prod(0x85d3)  tx_pkt_cons(0x85d3)  tx_bd_prod(0xcb2)  tx_bd_cons(0xcb1)  *tx_cons_sb(0x85d3)
[60072.331154] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp5: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331158] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp5: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331162] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f0)]     run indexes (0xb0dc 0x0)
[60072.331163] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f0)]     indexes (0x0 0x64a2 0x0 0x0 0x0 0x85d3 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60072.331189] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f0)]fp6: rx_bd_prod(0x7aa9)  rx_bd_cons(0x8e2)  rx_comp_prod(0x9484)  rx_comp_cons(0x92b7)  *rx_cons_sb(0x92b7)
[60072.331193] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x27f8)
[60072.331197] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp6: tx_pkt_prod(0x1edb)  tx_pkt_cons(0x1edb)  tx_bd_prod(0x3df3)  tx_bd_cons(0x3df2)  *tx_cons_sb(0x1edb)
[60072.331201] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp6: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331205] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp6: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331208] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f0)]     run indexes (0x27f8 0x0)
[60072.331209] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f0)]     indexes (0x0 0x92b7 0x0 0x0 0x0 0x1edb 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60072.331235] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f0)]fp7: rx_bd_prod(0xd2fe)  rx_bd_cons(0x137)  rx_comp_prod(0xdb9d)  rx_comp_cons(0xd9d1)  *rx_cons_sb(0xd9d1)
[60072.331239] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x8f11)
[60072.331243] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp7: tx_pkt_prod(0x25fc)  tx_pkt_cons(0x25fb)  tx_bd_prod(0x4c46)  tx_bd_cons(0x4c42)  *tx_cons_sb(0x25fb)
[60072.331247] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp7: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331251] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f0)]fp7: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60072.331254] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f0)]     run indexes (0x8f11 0x0)
[60072.331255] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f0)]     indexes (0x0 0xd9d1 0x0 0x0 0x0 0x25fb 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60072.331284] bnx2x 0018:01:00.0 enP24p1s0f0: bc 7.10.4
[60072.331290] begin fw dump (mark 0x3c6724)
[60072.331681] end of fw dump
[60072.331684] bnx2x: [bnx2x_mc_assert:720(enP24p1s0f0)]XSTORM_ASSERT_LIST_INDEX 0x2
[60072.331690] bnx2x: [bnx2x_mc_assert:736(enP24p1s0f0)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43e47 0x00463e01 0x00010052
[60072.331707] bnx2x: [bnx2x_mc_assert:750(enP24p1s0f0)]Chip Revision: everest3, FW Version: 7_13_1
[60072.331710] bnx2x: [bnx2x_panic_dump:1186(enP24p1s0f0)]end crash dump -----------------
[60075.481819] bnx2x: [bnx2x_stats_update:1232(enP24p1s0f2)]storm stats were not updated for 3 times
[60075.481832] bnx2x: [bnx2x_stats_update:1233(enP24p1s0f2)]driver assert
[60075.481844] bnx2x: [bnx2x_panic_dump:923(enP24p1s0f2)]begin crash dump -----------------
[60075.481849] bnx2x: [bnx2x_panic_dump:933(enP24p1s0f2)]def_idx(0xe520)  def_att_idx(0x6)  attn_state(0x0)  spq_prod_idx(0x39) next_stats_cnt(0xe516)
[60075.481855] bnx2x: [bnx2x_panic_dump:938(enP24p1s0f2)]DSB: attn bits(0x0)  ack(0x1)  id(0x0)  idx(0x6)
[60075.481859] bnx2x: [bnx2x_panic_dump:939(enP24p1s0f2)]     def (0x0 0x0 0x0 0x0 0x0 0x0 0x0 0xe606 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0)  igu_sb_id(0x44)  igu_seg_id(0x1) pf_id(0x1)  vnic_id(0x0)  vf_id(0xff)  vf_valid (0x0) state(0x1)
[60075.481880] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f2)]fp0: rx_bd_prod(0x2ae5)  rx_bd_cons(0xa65)  rx_comp_prod(0x2ed5)  rx_comp_cons(0x2e53)  *rx_cons_sb(0x2e53)
[60075.481886] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f2)]     rx_sge_prod(0x500)  last_max_sge(0x112)  fp_hc_idx(0xcc21)
[60075.481891] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp0: tx_pkt_prod(0xb195)  tx_pkt_cons(0xb195)  tx_bd_prod(0x6d6c)  tx_bd_cons(0x6d6b)  *tx_cons_sb(0xb195)
[60075.481898] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp0: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.481903] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp0: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.481908] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f2)]     run indexes (0xcc21 0x0)
[60075.481910] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f2)]     indexes (0x0 0x2e53 0x0 0x0 0x0 0xb195 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60075.481949] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f2)]fp1: rx_bd_prod(0x4963)  rx_bd_cons(0x8e3)  rx_comp_prod(0x4a98)  rx_comp_cons(0x4a16)  *rx_cons_sb(0x4a16)
[60075.481954] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f2)]     rx_sge_prod(0x480)  last_max_sge(0xb6)  fp_hc_idx(0xecc3)
[60075.481960] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp1: tx_pkt_prod(0xb2c6)  tx_pkt_cons(0xb2c5)  tx_bd_prod(0x6f6d)  tx_bd_cons(0x6f6a)  *tx_cons_sb(0xb2c5)
[60075.481965] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp1: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.481971] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp1: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.481975] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f2)]     run indexes (0xecc3 0x0)
[60075.481977] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f2)]     indexes (0x0 0x4a16 0x0 0x0 0x0 0xb2c5 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60075.482015] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f2)]fp2: rx_bd_prod(0xb91a)  rx_bd_cons(0x89a)  rx_comp_prod(0x44cb)  rx_comp_cons(0x4449)  *rx_cons_sb(0x4449)
[60075.482021] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f2)]     rx_sge_prod(0x4c0)  last_max_sge(0xf3)  fp_hc_idx(0xdd6b)
[60075.482026] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp2: tx_pkt_prod(0xb1d9)  tx_pkt_cons(0xb1d9)  tx_bd_prod(0x6e18)  tx_bd_cons(0x6e17)  *tx_cons_sb(0xb1d9)
[60075.482031] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp2: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482036] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp2: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482041] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f2)]     run indexes (0xdd6b 0x0)
[60075.482043] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f2)]     indexes (0x0 0x4449 0x0 0x0 0x0 0xb1d9 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60075.482080] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f2)]fp3: rx_bd_prod(0x998e)  rx_bd_cons(0x90e)  rx_comp_prod(0xee01)  rx_comp_cons(0xed7e)  *rx_cons_sb(0xed7e)
[60075.482086] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f2)]     rx_sge_prod(0x4c0)  last_max_sge(0xf3)  fp_hc_idx(0xb170)
[60075.482091] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp3: tx_pkt_prod(0xc93a)  tx_pkt_cons(0xc938)  tx_bd_prod(0x9d0f)  tx_bd_cons(0x9d0a)  *tx_cons_sb(0xc938)
[60075.482097] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp3: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482103] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp3: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482107] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f2)]     run indexes (0xb170 0x0)
[60075.482109] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f2)]     indexes (0x0 0xed7e 0x0 0x0 0x0 0xc938 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60075.482146] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f2)]fp4: rx_bd_prod(0xa1e)  rx_bd_cons(0x99c)  rx_comp_prod(0x691a)  rx_comp_cons(0x6898)  *rx_cons_sb(0x6898)
[60075.482152] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f2)]     rx_sge_prod(0x500)  last_max_sge(0x12d)  fp_hc_idx(0x83a5)
[60075.482157] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp4: tx_pkt_prod(0xb30f)  tx_pkt_cons(0xb30c)  tx_bd_prod(0x6ffb)  tx_bd_cons(0x6ff4)  *tx_cons_sb(0xb30c)
[60075.482163] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp4: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482167] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp4: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482173] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f2)]     run indexes (0x83a5 0x0)
[60075.482174] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f2)]     indexes (0x0 0x6898 0x0 0x0 0x0 0xb30c 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60075.482211] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f2)]fp5: rx_bd_prod(0x43da)  rx_bd_cons(0x35a)  rx_comp_prod(0x451b)  rx_comp_cons(0x4499)  *rx_cons_sb(0x4499)
[60075.482216] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f2)]     rx_sge_prod(0x4c0)  last_max_sge(0xce)  fp_hc_idx(0xe90d)
[60075.482221] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp5: tx_pkt_prod(0xb372)  tx_pkt_cons(0xb371)  tx_bd_prod(0x708a)  tx_bd_cons(0x7087)  *tx_cons_sb(0xb371)
[60075.482227] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp5: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482232] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp5: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482237] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f2)]     run indexes (0xe90d 0x0)
[60075.482239] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f2)]     indexes (0x0 0x4499 0x0 0x0 0x0 0xb371 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60075.482276] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f2)]fp6: rx_bd_prod(0x4064)  rx_bd_cons(0xfe2)  rx_comp_prod(0x7138)  rx_comp_cons(0x70b6)  *rx_cons_sb(0x70b6)
[60075.482281] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f2)]     rx_sge_prod(0x74c0)  last_max_sge(0x70c2)  fp_hc_idx(0x6fee)
[60075.482286] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp6: tx_pkt_prod(0xc033)  tx_pkt_cons(0xc032)  tx_bd_prod(0x8aaf)  tx_bd_cons(0x8aac)  *tx_cons_sb(0xc032)
[60075.482292] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp6: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482297] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp6: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482302] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f2)]     run indexes (0x6fee 0x0)
[60075.482303] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f2)]     indexes (0x0 0x70b6 0x0 0x0 0x0 0xc032 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60075.482342] bnx2x: [bnx2x_panic_dump:990(enP24p1s0f2)]fp7: rx_bd_prod(0x4302)  rx_bd_cons(0x282)  rx_comp_prod(0x4438)  rx_comp_cons(0x43b6)  *rx_cons_sb(0x43b6)
[60075.482347] bnx2x: [bnx2x_panic_dump:993(enP24p1s0f2)]     rx_sge_prod(0x540)  last_max_sge(0x144)  fp_hc_idx(0xee03)
[60075.482353] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp7: tx_pkt_prod(0xb8e7)  tx_pkt_cons(0xb8e6)  tx_bd_prod(0x7be7)  tx_bd_cons(0x7be4)  *tx_cons_sb(0xb8e6)
[60075.482358] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp7: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482363] bnx2x: [bnx2x_panic_dump:1010(enP24p1s0f2)]fp7: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60075.482368] bnx2x: [bnx2x_panic_dump:1021(enP24p1s0f2)]     run indexes (0xee03 0x0)
[60075.482370] bnx2x: [bnx2x_panic_dump:1027(enP24p1s0f2)]     indexes (0x0 0x43b6 0x0 0x0 0x0 0xb8e6 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60075.482411] bnx2x 0018:01:00.2 enP24p1s0f2: bc 7.10.4
[60075.482417] begin fw dump (mark 0x3c6724)
[60075.482837] end of fw dump
[60075.482841] bnx2x: [bnx2x_mc_assert:720(enP24p1s0f2)]XSTORM_ASSERT_LIST_INDEX 0x2
[60075.482849] bnx2x: [bnx2x_mc_assert:736(enP24p1s0f2)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43e47 0x00463e01 0x00010052
[60075.482868] bnx2x: [bnx2x_mc_assert:750(enP24p1s0f2)]Chip Revision: everest3, FW Version: 7_13_1
[60075.482872] bnx2x: [bnx2x_panic_dump:1186(enP24p1s0f2)]end crash dump -----------------
[60082.679313] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[0]: txdata->tx_pkt_prod(8476) != txdata->tx_pkt_cons(8475)
[60084.691653] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(7867) != txdata->tx_pkt_cons(7864)
[60086.703936] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(7898) != txdata->tx_pkt_cons(7894)
[60088.714354] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[5]: txdata->tx_pkt_prod(34272) != txdata->tx_pkt_cons(34259)
[60090.726489] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[6]: txdata->tx_pkt_prod(7900) != txdata->tx_pkt_cons(7899)
[60092.737306] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[7]: txdata->tx_pkt_prod(9724) != txdata->tx_pkt_cons(9723)
[60094.748509] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[0]: txdata->tx_pkt_prod(8476) != txdata->tx_pkt_cons(8475)
[60096.757971] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(7867) != txdata->tx_pkt_cons(7864)
[60098.768651] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(7898) != txdata->tx_pkt_cons(7894)
[60100.780366] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[5]: txdata->tx_pkt_prod(34272) != txdata->tx_pkt_cons(34259)
[60102.792871] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[6]: txdata->tx_pkt_prod(7900) != txdata->tx_pkt_cons(7899)
[60104.806225] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f0)]timeout waiting for queue[7]: txdata->tx_pkt_prod(9724) != txdata->tx_pkt_cons(9723)
[60104.809790] bnx2x: [bnx2x_del_all_macs:8501(enP24p1s0f0)]Failed to delete MACs: -5
[60104.809797] bnx2x: [bnx2x_chip_cleanup:9321(enP24p1s0f0)]Failed to schedule DEL commands for UC MACs list: -5
[60104.833774] bnx2x: [bnx2x_func_stop:9080(enP24p1s0f0)]FUNC_STOP ramrod failed. Running a dry transaction
[60105.011980] bnx2x: [bnx2x_flr_clnup_poll_hw_counter:1296(enP24p1s0f0)]CFC PF usage counter timed out usage count=8
[60105.011998] bnx2x 0018:01:00.0 enP24p1s0f0: bc 7.10.4
[60105.012004] begin fw dump (mark 0x3c6774)
[60105.012404] end of fw dump
[60105.012410] bnx2x: [bnx2x_nic_load:2722(enP24p1s0f0)]HW init failed, aborting
[60105.070295] bnx2x 0018:01:00.0 enP24p1s0f0: speed changed to 0 for port enP24p1s0f0
[60487.475116] ibmveth 30000009 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60489.710502] ibmveth 3000000a (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60502.603300] ibmveth 3000000f (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60505.382114] ibmveth 30000010 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60521.307081] ibmveth 30000015 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60522.468067] Unknown VPD Code: 0xfd
[60531.460692] Unknown VPD Code: 0xfd
[60534.795194] ibmveth 30000019 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60539.462088] Unknown VPD Code: 0xfd
[60546.261969] ibmveth 3000001c (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60548.461773] Unknown VPD Code: 0xfd
[60557.802758] ibmveth 3000001f (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60561.754192] ibmveth 30000020 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60567.462169] Unknown VPD Code: 0xfd
[60575.466460] Unknown VPD Code: 0xfd
[60588.693018] ibmveth 30000026 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60590.484390] Unknown VPD Code: 0xfd
[60598.585058] ibmveth 30000028 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60599.464037] Unknown VPD Code: 0xfd
[60608.109536] ibmveth 3000002a (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60613.182019] ibmveth 3000002b (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60615.465578] Unknown VPD Code: 0xfd
[60633.242435] ibmveth 3000002f (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60640.464170] Unknown VPD Code: 0xfd
[60654.378339] ibmveth 30000033 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60665.461887] Unknown VPD Code: 0xfd
[60665.466307] Unknown VPD Code: 0xfd
[60666.089092] ibmveth 30000035 (unnamed net_device) (uninitialized): unable to change checksum offload settings. 1 rc=0 ret_attr=a101
[60673.459592] Unknown VPD Code: 0xfd
[60682.461031] Unknown VPD Code: 0xfd
[60691.102735] ics_rtas_set_affinity: ibm,set-xive irq=655369 returns -3
[60691.102853] ics_rtas_set_affinity: ibm,set-xive irq=655371 returns -3
[60691.102960] ics_rtas_set_affinity: ibm,set-xive irq=655373 returns -3
[60699.460686] Unknown VPD Code: 0xfd
[60707.460300] Unknown VPD Code: 0xfd
[60711.102986] ics_rtas_set_affinity: ibm,set-xive irq=655367 returns -3
[60711.103053] ics_rtas_set_affinity: ibm,set-xive irq=655368 returns -3
[60711.103108] ics_rtas_set_affinity: ibm,set-xive irq=655369 returns -3
[60711.103167] ics_rtas_set_affinity: ibm,set-xive irq=655370 returns -3
[60711.103221] ics_rtas_set_affinity: ibm,set-xive irq=655371 returns -3
[60711.103325] ics_rtas_set_affinity: ibm,set-xive irq=655373 returns -3
[60760.873753] bnx2x: [bnx2x_attn_int_deasserted3:4323(enP30p128s0f0)]MC assert!
[60760.873775] bnx2x: [bnx2x_mc_assert:720(enP30p128s0f0)]XSTORM_ASSERT_LIST_INDEX 0x2
[60760.873784] bnx2x: [bnx2x_mc_assert:736(enP30p128s0f0)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43df9 0x00463db3 0x00010052
[60760.873808] bnx2x: [bnx2x_mc_assert:750(enP30p128s0f0)]Chip Revision: everest3, FW Version: 7_13_1
[60760.873812] bnx2x: [bnx2x_attn_int_deasserted3:4329(enP30p128s0f0)]driver assert
[60760.873816] bnx2x: [bnx2x_panic_dump:923(enP30p128s0f0)]begin crash dump -----------------
[60760.873821] bnx2x: [bnx2x_panic_dump:933(enP30p128s0f0)]def_idx(0xe7c0)  def_att_idx(0x4)  attn_state(0x1)  spq_prod_idx(0xd8) next_stats_cnt(0xe7b8)
[60760.873826] bnx2x: [bnx2x_panic_dump:938(enP30p128s0f0)]DSB: attn bits(0x0)  ack(0x1)  id(0x0)  idx(0x4)
[60760.873830] bnx2x: [bnx2x_panic_dump:939(enP30p128s0f0)]     def (0x0 0x0 0x0 0x0 0x0 0x0 0x0 0xe8a8 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0)  igu_sb_id(0x0)  igu_seg_id(0x1) pf_id(0x0)  vnic_id(0x0)  vf_id(0xff)  vf_valid (0x0) state(0x1)
[60760.873850] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f0)]fp0: rx_bd_prod(0x36d6)  rx_bd_cons(0x50f)  rx_comp_prod(0x3781)  rx_comp_cons(0x35b4)  *rx_cons_sb(0x35b4)
[60760.873855] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x2ec8)
[60760.873860] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp0: tx_pkt_prod(0x15d)  tx_pkt_cons(0x15c)  tx_bd_prod(0x2bd)  tx_bd_cons(0x2b9)  *tx_cons_sb(0x15c)
[60760.873866] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp0: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.873871] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp0: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.873876] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f0)]     run indexes (0x2ec8 0x0)
[60760.873878] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f0)]     indexes (0x0 0x35b4 0x0 0x0 0x0 0x15c 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60760.873915] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f0)]fp1: rx_bd_prod(0x580)  rx_bd_cons(0x3b9)  rx_comp_prod(0x595)  rx_comp_cons(0x3c9)  *rx_cons_sb(0x3c9)
[60760.873921] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x391)
[60760.873926] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp1: tx_pkt_prod(0x10a)  tx_pkt_cons(0x10a)  tx_bd_prod(0x216)  tx_bd_cons(0x215)  *tx_cons_sb(0x10a)
[60760.873931] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp1: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.873937] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp1: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.873942] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f0)]     run indexes (0x391 0x0)
[60760.873943] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f0)]     indexes (0x0 0x3c9 0x0 0x0 0x0 0x10a 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60760.873980] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f0)]fp2: rx_bd_prod(0x9fde)  rx_bd_cons(0xe19)  rx_comp_prod(0xa4d6)  rx_comp_cons(0xa30a)  *rx_cons_sb(0xa30a)
[60760.873985] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x3e52)
[60760.873990] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp2: tx_pkt_prod(0x392)  tx_pkt_cons(0x392)  tx_bd_prod(0x8d3)  tx_bd_cons(0x8d2)  *tx_cons_sb(0x392)
[60760.873995] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp2: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874001] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp2: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874005] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f0)]     run indexes (0x3e52 0x0)
[60760.874007] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f0)]     indexes (0x0 0xa30a 0x0 0x0 0x0 0x392 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60760.874043] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f0)]fp3: rx_bd_prod(0xaf77)  rx_bd_cons(0xdb0)  rx_comp_prod(0xb192)  rx_comp_cons(0xafc6)  *rx_cons_sb(0xafc6)
[60760.874049] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x7778)
[60760.874053] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp3: tx_pkt_prod(0x174)  tx_pkt_cons(0x174)  tx_bd_prod(0x2ea)  tx_bd_cons(0x2e9)  *tx_cons_sb(0x174)
[60760.874059] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp3: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874064] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp3: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874069] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f0)]     run indexes (0x7778 0x0)
[60760.874070] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f0)]     indexes (0x0 0xafc6 0x0 0x0 0x0 0x174 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60760.874107] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f0)]fp4: rx_bd_prod(0x5967)  rx_bd_cons(0x7a0)  rx_comp_prod(0x5a7b)  rx_comp_cons(0x58af)  *rx_cons_sb(0x58af)
[60760.874112] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x161d)
[60760.874117] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp4: tx_pkt_prod(0x1a5)  tx_pkt_cons(0x1a5)  tx_bd_prod(0x34d)  tx_bd_cons(0x34c)  *tx_cons_sb(0x1a5)
[60760.874123] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp4: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874128] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp4: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874133] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f0)]     run indexes (0x161d 0x0)
[60760.874134] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f0)]     indexes (0x0 0x58af 0x0 0x0 0x0 0x1a5 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60760.874171] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f0)]fp5: rx_bd_prod(0x5c4)  rx_bd_cons(0x3fd)  rx_comp_prod(0x5da)  rx_comp_cons(0x40e)  *rx_cons_sb(0x40e)
[60760.874176] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x651)
[60760.874183] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp5: tx_pkt_prod(0x29f)  tx_pkt_cons(0x29f)  tx_bd_prod(0x543)  tx_bd_cons(0x542)  *tx_cons_sb(0x29f)
[60760.874188] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp5: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874194] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp5: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874199] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f0)]     run indexes (0x651 0x0)
[60760.874200] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f0)]     indexes (0x0 0x40e 0x0 0x0 0x0 0x29f 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60760.874238] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f0)]fp6: rx_bd_prod(0x27ef)  rx_bd_cons(0x62a)  rx_comp_prod(0x286d)  rx_comp_cons(0x26a1)  *rx_cons_sb(0x26a1)
[60760.874244] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0x1e2b)
[60760.874249] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp6: tx_pkt_prod(0x117)  tx_pkt_cons(0x117)  tx_bd_prod(0x230)  tx_bd_cons(0x22f)  *tx_cons_sb(0x117)
[60760.874254] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp6: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874260] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp6: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874264] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f0)]     run indexes (0x1e2b 0x0)
[60760.874266] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f0)]     indexes (0x0 0x26a1 0x0 0x0 0x0 0x117 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60760.874302] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f0)]fp7: rx_bd_prod(0x39b)  rx_bd_cons(0x1d4)  rx_comp_prod(0x3aa)  rx_comp_cons(0x1de)  *rx_cons_sb(0x1de)
[60760.874308] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f0)]     rx_sge_prod(0x0)  last_max_sge(0x0)  fp_hc_idx(0xaaa)
[60760.874312] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp7: tx_pkt_prod(0x8e9)  tx_pkt_cons(0x8e9)  tx_bd_prod(0x11e3)  tx_bd_cons(0x11e2)  *tx_cons_sb(0x8e9)
[60760.874318] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp7: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874324] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f0)]fp7: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60760.874328] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f0)]     run indexes (0xaaa 0x0)
[60760.874330] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f0)]     indexes (0x0 0x1de 0x0 0x0 0x0 0x8e9 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60760.874370] bnx2x 001e:80:00.0 enP30p128s0f0: bc 7.10.4
[60760.874377] begin fw dump (mark 0x3c6524)
[60760.874905] end of fw dump
[60760.874909] bnx2x: [bnx2x_mc_assert:720(enP30p128s0f0)]XSTORM_ASSERT_LIST_INDEX 0x2
[60760.874918] bnx2x: [bnx2x_mc_assert:736(enP30p128s0f0)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43df9 0x00463db3 0x00010052
[60760.874941] bnx2x: [bnx2x_mc_assert:750(enP30p128s0f0)]Chip Revision: everest3, FW Version: 7_13_1
[60760.874945] bnx2x: [bnx2x_panic_dump:1186(enP30p128s0f0)]end crash dump -----------------
[60764.439813] bnx2x: [bnx2x_stats_update:1232(enP30p128s0f2)]storm stats were not updated for 3 times
[60764.439828] bnx2x: [bnx2x_stats_update:1233(enP30p128s0f2)]driver assert
[60764.439841] bnx2x: [bnx2x_panic_dump:923(enP30p128s0f2)]begin crash dump -----------------
[60764.439847] bnx2x: [bnx2x_panic_dump:933(enP30p128s0f2)]def_idx(0xe7b6)  def_att_idx(0x6)  attn_state(0x0)  spq_prod_idx(0xcf) next_stats_cnt(0xe7ab)
[60764.439853] bnx2x: [bnx2x_panic_dump:938(enP30p128s0f2)]DSB: attn bits(0x0)  ack(0x1)  id(0x0)  idx(0x6)
[60764.439858] bnx2x: [bnx2x_panic_dump:939(enP30p128s0f2)]     def (0x0 0x0 0x0 0x0 0x0 0x0 0x0 0xe89e 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0)  igu_sb_id(0x44)  igu_seg_id(0x1) pf_id(0x1)  vnic_id(0x0)  vf_id(0xff)  vf_valid (0x0) state(0x1)
[60764.439879] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f2)]fp0: rx_bd_prod(0xb8c9)  rx_bd_cons(0x849)  rx_comp_prod(0xbb58)  rx_comp_cons(0xbad6)  *rx_cons_sb(0xbad6)
[60764.439884] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f2)]     rx_sge_prod(0x480)  last_max_sge(0x90)  fp_hc_idx(0xcb1b)
[60764.439891] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp0: tx_pkt_prod(0x16d2)  tx_pkt_cons(0x16d2)  tx_bd_prod(0x37d4)  tx_bd_cons(0x37d3)  *tx_cons_sb(0x16d2)
[60764.439897] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp0: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.439902] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp0: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.439907] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f2)]     run indexes (0xcb1b 0x0)
[60764.439909] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f2)]     indexes (0x0 0xbad6 0x0 0x0 0x0 0x16d2 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60764.439953] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f2)]fp1: rx_bd_prod(0xa484)  rx_bd_cons(0x404)  rx_comp_prod(0xa6d2)  rx_comp_cons(0xa650)  *rx_cons_sb(0xa650)
[60764.439958] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f2)]     rx_sge_prod(0x480)  last_max_sge(0x94)  fp_hc_idx(0x3f53)
[60764.439963] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp1: tx_pkt_prod(0xc4ca)  tx_pkt_cons(0xc4ca)  tx_bd_prod(0xda80)  tx_bd_cons(0xda7f)  *tx_cons_sb(0xc4ca)
[60764.439969] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp1: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.439975] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp1: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.439979] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f2)]     run indexes (0x3f53 0x0)
[60764.439982] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f2)]     indexes (0x0 0xa650 0x0 0x0 0x0 0xc4ca 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60764.440025] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f2)]fp2: rx_bd_prod(0x3288)  rx_bd_cons(0x208)  rx_comp_prod(0x39ad)  rx_comp_cons(0x392b)  *rx_cons_sb(0x392b)
[60764.440030] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f2)]     rx_sge_prod(0x480)  last_max_sge(0x99)  fp_hc_idx(0x351e)
[60764.440036] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp2: tx_pkt_prod(0x99d0)  tx_pkt_cons(0x99cd)  tx_bd_prod(0x9f36)  tx_bd_cons(0x9f26)  *tx_cons_sb(0x99cd)
[60764.440042] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp2: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440047] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp2: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440052] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f2)]     run indexes (0x351e 0x0)
[60764.440054] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f2)]     indexes (0x0 0x392b 0x0 0x0 0x0 0x99cd 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60764.440094] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f2)]fp3: rx_bd_prod(0xfdd3)  rx_bd_cons(0xd53)  rx_comp_prod(0x13c)  rx_comp_cons(0xba)  *rx_cons_sb(0xba)
[60764.440100] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f2)]     rx_sge_prod(0x480)  last_max_sge(0xa2)  fp_hc_idx(0xe3f0)
[60764.440105] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp3: tx_pkt_prod(0x1aa9)  tx_pkt_cons(0x1aa9)  tx_bd_prod(0x3fee)  tx_bd_cons(0x3fed)  *tx_cons_sb(0x1aa9)
[60764.440111] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp3: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440117] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp3: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440122] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f2)]     run indexes (0xe3f0 0x0)
[60764.440123] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f2)]     indexes (0x0 0xba 0x0 0x0 0x0 0x1aa9 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60764.440165] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f2)]fp4: rx_bd_prod(0xfc6d)  rx_bd_cons(0xbeb)  rx_comp_prod(0xe)  rx_comp_cons(0xff8c)  *rx_cons_sb(0xff8c)
[60764.440170] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f2)]     rx_sge_prod(0x540)  last_max_sge(0x14d)  fp_hc_idx(0xca9b)
[60764.440175] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp4: tx_pkt_prod(0x1578)  tx_pkt_cons(0x1578)  tx_bd_prod(0x33ca)  tx_bd_cons(0x33c9)  *tx_cons_sb(0x1578)
[60764.440181] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp4: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440185] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp4: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440191] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f2)]     run indexes (0xca9b 0x0)
[60764.440192] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f2)]     indexes (0x0 0xff8c 0x0 0x0 0x0 0x1578 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60764.440235] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f2)]fp5: rx_bd_prod(0xa37a)  rx_bd_cons(0x2fa)  rx_comp_prod(0xa5ba)  rx_comp_cons(0xa538)  *rx_cons_sb(0xa538)
[60764.440240] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f2)]     rx_sge_prod(0x480)  last_max_sge(0x83)  fp_hc_idx(0xb59c)
[60764.440245] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp5: tx_pkt_prod(0x1636)  tx_pkt_cons(0x1636)  tx_bd_prod(0x35e9)  tx_bd_cons(0x35e8)  *tx_cons_sb(0x1636)
[60764.440251] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp5: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440256] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp5: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440261] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f2)]     run indexes (0xb59c 0x0)
[60764.440263] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f2)]     indexes (0x0 0xa538 0x0 0x0 0x0 0x1636 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60764.440303] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f2)]fp6: rx_bd_prod(0xb1f9)  rx_bd_cons(0x179)  rx_comp_prod(0xc531)  rx_comp_cons(0xc4af)  *rx_cons_sb(0xc4af)
[60764.440308] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f2)]     rx_sge_prod(0xeb80)  last_max_sge(0xe77f)  fp_hc_idx(0xe607)
[60764.440313] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp6: tx_pkt_prod(0x161e)  tx_pkt_cons(0x161e)  tx_bd_prod(0x35e7)  tx_bd_cons(0x35e6)  *tx_cons_sb(0x161e)
[60764.440319] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp6: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440324] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp6: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440329] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f2)]     run indexes (0xe607 0x0)
[60764.440330] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f2)]     indexes (0x0 0xc4af 0x0 0x0 0x0 0x161e 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60764.440372] bnx2x: [bnx2x_panic_dump:990(enP30p128s0f2)]fp7: rx_bd_prod(0xa274)  rx_bd_cons(0x1f2)  rx_comp_prod(0xa4c7)  rx_comp_cons(0xa445)  *rx_cons_sb(0xa445)
[60764.440377] bnx2x: [bnx2x_panic_dump:993(enP30p128s0f2)]     rx_sge_prod(0x480)  last_max_sge(0xae)  fp_hc_idx(0xbd4d)
[60764.440382] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp7: tx_pkt_prod(0x1f29)  tx_pkt_cons(0x1f29)  tx_bd_prod(0x482c)  tx_bd_cons(0x482b)  *tx_cons_sb(0x1f29)
[60764.440388] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp7: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440393] bnx2x: [bnx2x_panic_dump:1010(enP30p128s0f2)]fp7: tx_pkt_prod(0x0)  tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[60764.440397] bnx2x: [bnx2x_panic_dump:1021(enP30p128s0f2)]     run indexes (0xbd4d 0x0)
[60764.440399] bnx2x: [bnx2x_panic_dump:1027(enP30p128s0f2)]     indexes (0x0 0xa445 0x0 0x0 0x0 0x1f29 0x0 0x0)pf_id(0x1)  vf_id(0xff)  vf_valid(0x0) vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[60764.440443] bnx2x 001e:80:00.2 enP30p128s0f2: bc 7.10.4
[60764.440451] begin fw dump (mark 0x3c6524)
[60764.440976] end of fw dump
[60764.440981] bnx2x: [bnx2x_mc_assert:720(enP30p128s0f2)]XSTORM_ASSERT_LIST_INDEX 0x2
[60764.440989] bnx2x: [bnx2x_mc_assert:736(enP30p128s0f2)]XSTORM_ASSERT_INDEX 0x0 = 0x00000000 0x25e43df9 0x00463db3 0x00010052
[60764.441013] bnx2x: [bnx2x_mc_assert:750(enP30p128s0f2)]Chip Revision: everest3, FW Version: 7_13_1
[60764.441017] bnx2x: [bnx2x_panic_dump:1186(enP30p128s0f2)]end crash dump -----------------
[60773.620017] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[0]: txdata->tx_pkt_prod(349) != txdata->tx_pkt_cons(348)
[60775.632359] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(276) != txdata->tx_pkt_cons(266)
[60777.640531] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(915) != txdata->tx_pkt_cons(914)
[60779.649798] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[3]: txdata->tx_pkt_prod(373) != txdata->tx_pkt_cons(372)
[60781.661792] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[4]: txdata->tx_pkt_prod(422) != txdata->tx_pkt_cons(421)
[60783.674166] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[5]: txdata->tx_pkt_prod(675) != txdata->tx_pkt_cons(671)
[60785.686835] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[6]: txdata->tx_pkt_prod(294) != txdata->tx_pkt_cons(279)
[60787.700171] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[7]: txdata->tx_pkt_prod(2293) != txdata->tx_pkt_cons(2281)
[60789.713792] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[0]: txdata->tx_pkt_prod(349) != txdata->tx_pkt_cons(348)
[60791.730113] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(276) != txdata->tx_pkt_cons(266)
[60793.746280] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(915) != txdata->tx_pkt_cons(914)
[60795.762117] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[3]: txdata->tx_pkt_prod(373) != txdata->tx_pkt_cons(372)
[60797.778579] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[4]: txdata->tx_pkt_prod(422) != txdata->tx_pkt_cons(421)
[60799.794700] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[5]: txdata->tx_pkt_prod(675) != txdata->tx_pkt_cons(671)
[60801.812897] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[6]: txdata->tx_pkt_prod(294) != txdata->tx_pkt_cons(279)
[60803.830978] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f0)]timeout waiting for queue[7]: txdata->tx_pkt_prod(2293) != txdata->tx_pkt_cons(2281)
[60803.835043] bnx2x: [bnx2x_del_all_macs:8501(enP30p128s0f0)]Failed to delete MACs: -5
[60803.835049] bnx2x: [bnx2x_chip_cleanup:9321(enP30p128s0f0)]Failed to schedule DEL commands for UC MACs list: -5
[60803.855737] bnx2x: [bnx2x_func_stop:9080(enP30p128s0f0)]FUNC_STOP ramrod failed. Running a dry transaction
[60804.033992] bnx2x: [bnx2x_flr_clnup_poll_hw_counter:1296(enP30p128s0f0)]CFC PF usage counter timed out usage count=8
[60804.034012] bnx2x 001e:80:00.0 enP30p128s0f0: bc 7.10.4
[60804.034018] begin fw dump (mark 0x3c6574)
[60804.034536] end of fw dump
[60804.034542] bnx2x: [bnx2x_nic_load:2722(enP30p128s0f0)]HW init failed, aborting
[60804.092357] bnx2x 001e:80:00.0 enP30p128s0f0: speed changed to 0 for port enP30p128s0f0
[60900.119619] INFO: task kworker/24:3:19463 blocked for more than 120 seconds.
[60900.119635]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[60900.119638] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[60900.119747] INFO: task kworker/16:1:11309 blocked for more than 120 seconds.
[60900.119750]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[60900.119752] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[60900.119845] INFO: task kworker/1:2:17629 blocked for more than 120 seconds.
[60900.119848]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[60900.119850] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[60900.119940] INFO: task kworker/8:3:19694 blocked for more than 120 seconds.
[60900.119943]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[60900.119945] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[60900.120032] INFO: task kworker/24:4:22639 blocked for more than 120 seconds.
[60900.120034]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[60900.120037] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[60900.120121] INFO: task kworker/1:6:23846 blocked for more than 120 seconds.
[60900.120124]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[60900.120126] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[61020.951258] INFO: task kworker/24:3:19463 blocked for more than 120 seconds.
[61020.951276]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[61020.951279] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[61020.951389] INFO: task kworker/16:1:11309 blocked for more than 120 seconds.
[61020.951392]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[61020.951394] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[61020.951486] INFO: task kworker/1:2:17629 blocked for more than 120 seconds.
[61020.951489]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[61020.951491] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[61020.951581] INFO: task kworker/8:3:19694 blocked for more than 120 seconds.
[61020.951584]       Tainted: G        W  OE   4.11.0-041100-generic #201705041534
[61020.951586] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[61344.754891] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[1]: txdata->tx_pkt_prod(50382) != txdata->tx_pkt_cons(50378)
[61346.770627] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[2]: txdata->tx_pkt_prod(39377) != txdata->tx_pkt_cons(39373)
[61348.784316] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[3]: txdata->tx_pkt_prod(7452) != txdata->tx_pkt_cons(6825)
[61350.802315] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[4]: txdata->tx_pkt_prod(5500) != txdata->tx_pkt_cons(5496)
[61352.822720] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[5]: txdata->tx_pkt_prod(5689) != txdata->tx_pkt_cons(5686)
[61354.836610] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[6]: txdata->tx_pkt_prod(5663) != txdata->tx_pkt_cons(5662)
[61356.856177] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[7]: txdata->tx_pkt_prod(8000) != txdata->tx_pkt_cons(7977)
[61358.868256] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[1]: txdata->tx_pkt_prod(50382) != txdata->tx_pkt_cons(50378)
[61360.888612] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[2]: txdata->tx_pkt_prod(39377) != txdata->tx_pkt_cons(39373)
[61362.907396] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[3]: txdata->tx_pkt_prod(7452) != txdata->tx_pkt_cons(6825)
[61364.923391] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[4]: txdata->tx_pkt_prod(5500) != txdata->tx_pkt_cons(5496)
[61366.936149] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[5]: txdata->tx_pkt_prod(5689) != txdata->tx_pkt_cons(5686)
[61368.957430] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[6]: txdata->tx_pkt_prod(5663) != txdata->tx_pkt_cons(5662)
[61370.970463] bnx2x: [bnx2x_clean_tx_queue:1205(enP30p128s0f2)]timeout waiting for queue[7]: txdata->tx_pkt_prod(8000) != txdata->tx_pkt_cons(7977)
[61370.974118] bnx2x: [bnx2x_del_all_macs:8501(enP30p128s0f2)]Failed to delete MACs: -5
[61370.974128] bnx2x: [bnx2x_chip_cleanup:9321(enP30p128s0f2)]Failed to schedule DEL commands for UC MACs list: -5
[61370.998105] bnx2x: [bnx2x_func_stop:9080(enP30p128s0f2)]FUNC_STOP ramrod failed. Running a dry transaction
[61371.696099] bnx2x: [bnx2x_nic_load:2753(enP30p128s0f2)]Function start failed!
[61371.754320] bnx2x 001e:80:00.2 enP30p128s0f2: speed changed to 0 for port enP30p128s0f2
[61691.632291] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[0]: txdata->tx_pkt_prod(45512) != txdata->tx_pkt_cons(45461)
[61693.653503] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[1]: txdata->tx_pkt_prod(45827) != txdata->tx_pkt_cons(45765)
[61695.671123] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[2]: txdata->tx_pkt_prod(45571) != txdata->tx_pkt_cons(45529)
[61697.687133] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[3]: txdata->tx_pkt_prod(52084) != txdata->tx_pkt_cons(51512)
[61699.697993] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[4]: txdata->tx_pkt_prod(45893) != txdata->tx_pkt_cons(45836)
[61701.716654] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[5]: txdata->tx_pkt_prod(45980) != txdata->tx_pkt_cons(45937)
[61703.733489] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[6]: txdata->tx_pkt_prod(49251) != txdata->tx_pkt_cons(49202)
[61705.747094] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[7]: txdata->tx_pkt_prod(47447) != txdata->tx_pkt_cons(47334)
[61707.767683] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[0]: txdata->tx_pkt_prod(45512) != txdata->tx_pkt_cons(45461)
[61709.779342] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[1]: txdata->tx_pkt_prod(45827) != txdata->tx_pkt_cons(45765)
[61711.797600] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[2]: txdata->tx_pkt_prod(45571) != txdata->tx_pkt_cons(45529)
[61713.817255] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[3]: txdata->tx_pkt_prod(52084) != txdata->tx_pkt_cons(51512)
[61715.838415] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[4]: txdata->tx_pkt_prod(45893) != txdata->tx_pkt_cons(45836)
[61717.858064] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[5]: txdata->tx_pkt_prod(45980) != txdata->tx_pkt_cons(45937)
[61719.879706] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[6]: txdata->tx_pkt_prod(49251) != txdata->tx_pkt_cons(49202)
[61721.890224] bnx2x: [bnx2x_clean_tx_queue:1205(enP24p1s0f2)]timeout waiting for queue[7]: txdata->tx_pkt_prod(47447) != txdata->tx_pkt_cons(47334)
[61721.894311] bnx2x: [bnx2x_del_all_macs:8501(enP24p1s0f2)]Failed to delete MACs: -5
[61721.894318] bnx2x: [bnx2x_chip_cleanup:9321(enP24p1s0f2)]Failed to schedule DEL commands for UC MACs list: -5
[61721.917093] bnx2x: [bnx2x_func_stop:9080(enP24p1s0f2)]FUNC_STOP ramrod failed. Running a dry transaction
[61722.615051] bnx2x: [bnx2x_nic_load:2753(enP24p1s0f2)]Function start failed!
[61722.673242] bnx2x 0018:01:00.2 enP24p1s0f2: speed changed to 0 for port enP24p1s0f2
