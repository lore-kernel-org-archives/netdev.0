From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Sun, 21 May 2017 01:31:40 +0530
Message-ID: <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
 <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
 <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com>
 <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com> <591A07A1.1030006@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kees Cook <keescook@chromium.org>,
        David Miller <davem@davemloft.net>,
        Mircea Gherzan <mgherzan@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:34731 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756506AbdETUBm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 16:01:42 -0400
Received: by mail-oi0-f51.google.com with SMTP id b204so125255406oii.1
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 13:01:42 -0700 (PDT)
In-Reply-To: <591A07A1.1030006@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel and Kees,

Before I send the patch, I have tested the JIT compiler on ARMv7 but
not on ARMv5 or ARMv6. So can you tell me which arch versions I should
test it for?
Also for my testing, CONFIG_FRAME_POINTER and CONFIG_CPU_BIG_ENDIAN
are both disabled. But I need to test JIT with these flags as well.
Whenever I put these flags in .config file, the arm kernel is not
getting compiler with these flags. Can you tell me why? If you need
more information regarding this, please let me know.

With current config for ARMv7, benchmarks are :

[root@vexpress modules]# insmod test_bpf.ko
[   25.797766] test_bpf: #0 TAX jited:1 180 170 169 PASS
[   25.811395] test_bpf: #1 TXA jited:1 93 89 111 PASS
[   25.815073] test_bpf: #2 ADD_SUB_MUL_K jited:1 94 PASS
[   25.816779] test_bpf: #3 DIV_MOD_KX jited:1 983 PASS
[   25.827310] test_bpf: #4 AND_OR_LSH_K jited:1 94 93 PASS
[   25.829843] test_bpf: #5 LD_IMM_0 jited:1 83 PASS
[   25.831260] test_bpf: #6 LD_IND jited:1 338 266 305 PASS
[   25.840970] test_bpf: #7 LD_ABS jited:1 343 304 289 PASS
[   25.851005] test_bpf: #8 LD_ABS_LL jited:1 362 300 PASS
[   25.858119] test_bpf: #9 LD_IND_LL jited:1 244 241 245 PASS
[   25.865994] test_bpf: #10 LD_ABS_NET jited:1 318 316 PASS
[   25.872829] test_bpf: #11 LD_IND_NET jited:1 243 196 196 PASS
[   25.879717] test_bpf: #12 LD_PKTTYPE jited:1 129 140 PASS
[   25.883034] test_bpf: #13 LD_MARK jited:1 113 88 PASS
[   25.885545] test_bpf: #14 LD_RXHASH jited:1 81 79 PASS
[   25.887506] test_bpf: #15 LD_QUEUE jited:1 88 85 PASS
[   25.889593] test_bpf: #16 LD_PROTOCOL jited:1 322 353 PASS
[   25.896894] test_bpf: #17 LD_VLAN_TAG jited:1 92 92 PASS
[   25.899173] test_bpf: #18 LD_VLAN_TAG_PRESENT jited:1 85 88 PASS
[   25.901310] test_bpf: #19 LD_IFINDEX jited:1 94 130 PASS
[   25.904110] test_bpf: #20 LD_HATYPE jited:1 98 91 PASS
[   25.906393] test_bpf: #21 LD_CPU
[   25.906651] bpf_jit: *** NOT YET: opcode 85 ***
[   25.906795] jited:0 705 691 PASS
[   25.921007] test_bpf: #22 LD_NLATTR jited:0 577 668 PASS
[   25.933870] test_bpf: #23 LD_NLATTR_NEST jited:0 2253 3006 PASS
[   25.987020] test_bpf: #24 LD_PAYLOAD_OFF jited:0 3840 4922 PASS
[   26.075119] test_bpf: #25 LD_ANC_XOR jited:1 107 94 PASS
[   26.077583] test_bpf: #26 SPILL_FILL jited:1 159 148 173 PASS
[   26.083259] test_bpf: #27 JEQ jited:1 274 183 181 PASS
[   26.090383] test_bpf: #28 JGT jited:1 255 194 165 PASS
[   26.097163] test_bpf: #29 JGE jited:1 187 190 246 PASS
[   26.103932] test_bpf: #30 JSET jited:1 178 184 192 PASS
[   26.110229] test_bpf: #31 tcpdump port 22 jited:1 266 698 717 PASS
[   26.127698] test_bpf: #32 tcpdump complex jited:1 267 729 1129 PASS
[   26.149727] test_bpf: #33 RET_A jited:1 94 88 PASS
[   26.152114] test_bpf: #34 INT: ADD trivial jited:1 87 PASS
[   26.153900] test_bpf: #35 INT: MUL_X jited:1 95 PASS
[   26.155384] test_bpf: #36 INT: MUL_X2 jited:1 82 PASS
[   26.156606] test_bpf: #37 INT: MUL32_X jited:1 91 PASS
[   26.157846] test_bpf: #38 INT: ADD 64-bit jited:1 1055 PASS
[   26.169280] test_bpf: #39 INT: ADD 32-bit jited:1 701 PASS
[   26.177039] test_bpf: #40 INT: SUB jited:1 931 PASS
[   26.187108] test_bpf: #41 INT: XOR jited:1 355 PASS
[   26.191364] test_bpf: #42 INT: MUL jited:1 389 PASS
[   26.196286] test_bpf: #43 MOV REG64 jited:1 267 PASS
[   26.199759] test_bpf: #44 MOV REG32 jited:1 176 PASS
[   26.202060] test_bpf: #45 LD IMM64 jited:1 194 PASS
[   26.204607] test_bpf: #46 INT: ALU MIX jited:0 1174 PASS
[   26.216896] test_bpf: #47 INT: shifts by register jited:1 211 PASS
[   26.219956] test_bpf: #48 INT: DIV + ABS jited:1 559 517 PASS
[   26.231347] test_bpf: #49 INT: DIV by zero jited:1 395 277 PASS
[   26.238862] test_bpf: #50 check: missing ret PASS
[   26.239288] test_bpf: #51 check: div_k_0 PASS
[   26.239492] test_bpf: #52 check: unknown insn PASS
[   26.239640] test_bpf: #53 check: out of range spill/fill PASS
[   26.239803] test_bpf: #54 JUMPS + HOLES jited:1 295 PASS
[   26.243343] test_bpf: #55 check: RET X PASS
[   26.244065] test_bpf: #56 check: LDX + RET X PASS
[   26.244224] test_bpf: #57 M[]: alt STX + LDX jited:1 433 PASS
[   26.249126] test_bpf: #58 M[]: full STX + full LDX jited:1 427 PASS
[   26.254123] test_bpf: #59 check: SKF_AD_MAX PASS
[   26.254509] test_bpf: #60 LD [SKF_AD_OFF-1] jited:1 298 PASS
[   26.257882] test_bpf: #61 load 64-bit immediate jited:1 128 PASS
[   26.259813] test_bpf: #62 nmap reduced jited:1 655 PASS
[   26.267216] test_bpf: #63 ALU_MOV_X: dst = 2 jited:1 89 PASS
[   26.268766] test_bpf: #64 ALU_MOV_X: dst = 4294967295 jited:1 72 PASS
[   26.270126] test_bpf: #65 ALU64_MOV_X: dst = 2 jited:1 94 PASS
[   26.271768] test_bpf: #66 ALU64_MOV_X: dst = 4294967295 jited:1 145 PASS
[   26.274152] test_bpf: #67 ALU_MOV_K: dst = 2 jited:1 93 PASS
[   26.275673] test_bpf: #68 ALU_MOV_K: dst = 4294967295 jited:1 103 PASS
[   26.277371] test_bpf: #69 ALU_MOV_K: 0x0000ffffffff0000 =
0x00000000ffffffff jited:1 99 PASS
[   26.278966] test_bpf: #70 ALU64_MOV_K: dst = 2 jited:1 110 PASS
[   26.280440] test_bpf: #71 ALU64_MOV_K: dst = 2147483647 jited:1 96 PASS
[   26.281843] test_bpf: #72 ALU64_OR_K: dst = 0x0 jited:1 103 PASS
[   26.283682] test_bpf: #73 ALU64_MOV_K: dst = -1 jited:1 96 PASS
[   26.285147] test_bpf: #74 ALU_ADD_X: 1 + 2 = 3 jited:1 85 PASS
[   26.286373] test_bpf: #75 ALU_ADD_X: 1 + 4294967294 = 4294967295
jited:1 108 PASS
[   26.288079] test_bpf: #76 ALU_ADD_X: 2 + 4294967294 = 0 jited:1 112 PASS
[   26.289653] test_bpf: #77 ALU64_ADD_X: 1 + 2 = 3 jited:1 70 PASS
[   26.290666] test_bpf: #78 ALU64_ADD_X: 1 + 4294967294 = 4294967295
jited:1 85 PASS
[   26.291897] test_bpf: #79 ALU64_ADD_X: 2 + 4294967294 = 4294967296
jited:1 95 PASS
[   26.293429] test_bpf: #80 ALU_ADD_K: 1 + 2 = 3 jited:1 96 PASS
[   26.294794] test_bpf: #81 ALU_ADD_K: 3 + 0 = 3 jited:1 79 PASS
[   26.295956] test_bpf: #82 ALU_ADD_K: 1 + 4294967294 = 4294967295
jited:1 70 PASS
[   26.297026] test_bpf: #83 ALU_ADD_K: 4294967294 + 2 = 0 jited:1 77 PASS
[   26.298109] test_bpf: #84 ALU_ADD_K: 0 + (-1) = 0x00000000ffffffff
jited:1 120 PASS
[   26.299705] test_bpf: #85 ALU_ADD_K: 0 + 0xffff = 0xffff jited:1 85 PASS
[   26.300902] test_bpf: #86 ALU_ADD_K: 0 + 0x7fffffff = 0x7fffffff
jited:1 121 PASS
[   26.302578] test_bpf: #87 ALU_ADD_K: 0 + 0x80000000 = 0x80000000
jited:1 115 PASS
[   26.304134] test_bpf: #88 ALU_ADD_K: 0 + 0x80008000 = 0x80008000
jited:1 136 PASS
[   26.305881] test_bpf: #89 ALU64_ADD_K: 1 + 2 = 3 jited:1 119 PASS
[   26.307481] test_bpf: #90 ALU64_ADD_K: 3 + 0 = 3 jited:1 90 PASS
[   26.308784] test_bpf: #91 ALU64_ADD_K: 1 + 2147483646 = 2147483647
jited:1 83 PASS
[   26.310091] test_bpf: #92 ALU64_ADD_K: 4294967294 + 2 = 4294967296
jited:1 82 PASS
[   26.311534] test_bpf: #93 ALU64_ADD_K: 2147483646 + -2147483647 =
-1 jited:1 71 PASS
[   26.312842] test_bpf: #94 ALU64_ADD_K: 1 + 0 = 1 jited:1 143 PASS
[   26.315010] test_bpf: #95 ALU64_ADD_K: 0 + (-1) =
0xffffffffffffffff jited:1 116 PASS
[   26.317106] test_bpf: #96 ALU64_ADD_K: 0 + 0xffff = 0xffff jited:1 119 PASS
[   26.318834] test_bpf: #97 ALU64_ADD_K: 0 + 0x7fffffff = 0x7fffffff
jited:1 119 PASS
[   26.320484] test_bpf: #98 ALU64_ADD_K: 0 + 0x80000000 =
0xffffffff80000000 jited:1 110 PASS
[   26.322003] test_bpf: #99 ALU_ADD_K: 0 + 0x80008000 =
0xffffffff80008000 jited:1 117 PASS
[   26.323841] test_bpf: #100 ALU_SUB_X: 3 - 1 = 2 jited:1 84 PASS
[   26.325043] test_bpf: #101 ALU_SUB_X: 4294967295 - 4294967294 = 1
jited:1 84 PASS
[   26.326300] test_bpf: #102 ALU64_SUB_X: 3 - 1 = 2 jited:1 97 PASS
[   26.327661] test_bpf: #103 ALU64_SUB_X: 4294967295 - 4294967294 = 1
jited:1 74 PASS
[   26.328760] test_bpf: #104 ALU_SUB_K: 3 - 1 = 2 jited:1 80 PASS
[   26.329880] test_bpf: #105 ALU_SUB_K: 3 - 0 = 3 jited:1 93 PASS
[   26.331166] test_bpf: #106 ALU_SUB_K: 4294967295 - 4294967294 = 1
jited:1 81 PASS
[   26.332348] test_bpf: #107 ALU64_SUB_K: 3 - 1 = 2 jited:1 89 PASS
[   26.333616] test_bpf: #108 ALU64_SUB_K: 3 - 0 = 3 jited:1 73 PASS
[   26.334796] test_bpf: #109 ALU64_SUB_K: 4294967294 - 4294967295 =
-1 jited:1 75 PASS
[   26.335880] test_bpf: #110 ALU64_ADD_K: 2147483646 - 2147483647 =
-1 jited:1 88 PASS
[   26.337138] test_bpf: #111 ALU_MUL_X: 2 * 3 = 6 jited:1 113 PASS
[   26.338609] test_bpf: #112 ALU_MUL_X: 2 * 0x7FFFFFF8 = 0xFFFFFFF0
jited:1 99 PASS
[   26.339983] test_bpf: #113 ALU_MUL_X: -1 * -1 = 1 jited:1 70 PASS
[   26.341036] test_bpf: #114 ALU64_MUL_X: 2 * 3 = 6 jited:1 75 PASS
[   26.342242] test_bpf: #115 ALU64_MUL_X: 1 * 2147483647 = 2147483647
jited:1 91 PASS
[   26.343719] test_bpf: #116 ALU_MUL_K: 2 * 3 = 6 jited:1 83 PASS
[   26.344945] test_bpf: #117 ALU_MUL_K: 3 * 1 = 3 jited:1 84 PASS
[   26.346135] test_bpf: #118 ALU_MUL_K: 2 * 0x7FFFFFF8 = 0xFFFFFFF0
jited:1 69 PASS
[   26.347240] test_bpf: #119 ALU_MUL_K: 1 * (-1) = 0x00000000ffffffff
jited:1 99 PASS
[   26.348596] test_bpf: #120 ALU64_MUL_K: 2 * 3 = 6 jited:1 73 PASS
[   26.349749] test_bpf: #121 ALU64_MUL_K: 3 * 1 = 3 jited:1 89 PASS
[   26.350992] test_bpf: #122 ALU64_MUL_K: 1 * 2147483647 = 2147483647
jited:1 101 PASS
[   26.352436] test_bpf: #123 ALU64_MUL_K: 1 * -2147483647 =
-2147483647 jited:1 112 PASS
[   26.354144] test_bpf: #124 ALU64_MUL_K: 1 * (-1) =
0xffffffffffffffff jited:1 145 PASS
[   26.356392] test_bpf: #125 ALU_DIV_X: 6 / 2 = 3 jited:1 204 PASS
[   26.359242] test_bpf: #126 ALU_DIV_X: 4294967295 / 4294967295 = 1
jited:1 232 PASS
[   26.362516] test_bpf: #127 ALU64_DIV_X: 6 / 2 = 3 jited:0 593 PASS
[   26.368978] test_bpf: #128 ALU64_DIV_X: 2147483647 / 2147483647 = 1
jited:0 517 PASS
[   26.374539] test_bpf: #129 ALU64_DIV_X: 0xffffffffffffffff / (-1) =
0x0000000000000001 jited:0 666 PASS
[   26.381642] test_bpf: #130 ALU_DIV_K: 6 / 2 = 3 jited:1 225 PASS
[   26.384418] test_bpf: #131 ALU_DIV_K: 3 / 1 = 3 jited:1 199 PASS
[   26.386820] test_bpf: #132 ALU_DIV_K: 4294967295 / 4294967295 = 1
jited:1 195 PASS
[   26.389428] test_bpf: #133 ALU_DIV_K: 0xffffffffffffffff / (-1) =
0x1 jited:1 354 PASS
[   26.393537] test_bpf: #134 ALU64_DIV_K: 6 / 2 = 3 jited:0 403 PASS
[   26.398414] test_bpf: #135 ALU64_DIV_K: 3 / 1 = 3 jited:0 388 PASS
[   26.403006] test_bpf: #136 ALU64_DIV_K: 2147483647 / 2147483647 = 1
jited:0 387 PASS
[   26.407619] test_bpf: #137 ALU64_DIV_K: 0xffffffffffffffff / (-1) =
0x0000000000000001 jited:0 577 PASS
[   26.413875] test_bpf: #138 ALU_MOD_X: 3 % 2 = 1 jited:1 284 PASS
[   26.417106] test_bpf: #139 ALU_MOD_X: 4294967295 % 4294967293 = 2
jited:1 298 PASS
[   26.420489] test_bpf: #140 ALU64_MOD_X: 3 % 2 = 1 jited:0 609 PASS
[   26.426958] test_bpf: #141 ALU64_MOD_X: 2147483647 % 2147483645 = 2
jited:0 588 PASS
[   26.433454] test_bpf: #142 ALU_MOD_K: 3 % 2 = 1 jited:1 301 PASS
[   26.436831] test_bpf: #143 ALU_MOD_K: 3 % 1 = 0 jited:1 PASS
[   26.437152] test_bpf: #144 ALU_MOD_K: 4294967295 % 4294967293 = 2
jited:1 316 PASS
[   26.440713] test_bpf: #145 ALU64_MOD_K: 3 % 2 = 1 jited:0 612 PASS
[   26.447535] test_bpf: #146 ALU64_MOD_K: 3 % 1 = 0 jited:0 PASS
[   26.448057] test_bpf: #147 ALU64_MOD_K: 2147483647 % 2147483645 = 2
jited:0 612 PASS
[   26.454579] test_bpf: #148 ALU_AND_X: 3 & 2 = 2 jited:1 112 PASS
[   26.456065] test_bpf: #149 ALU_AND_X: 0xffffffff & 0xffffffff =
0xffffffff jited:1 76 PASS
[   26.457168] test_bpf: #150 ALU64_AND_X: 3 & 2 = 2 jited:1 84 PASS
[   26.458350] test_bpf: #151 ALU64_AND_X: 0xffffffff & 0xffffffff =
0xffffffff jited:1 78 PASS
[   26.459582] test_bpf: #152 ALU_AND_K: 3 & 2 = 2 jited:1 81 PASS
[   26.460724] test_bpf: #153 ALU_AND_K: 0xffffffff & 0xffffffff =
0xffffffff jited:1 89 PASS
[   26.462005] test_bpf: #154 ALU64_AND_K: 3 & 2 = 2 jited:1 99 PASS
[   26.463622] test_bpf: #155 ALU64_AND_K: 0xffffffff & 0xffffffff =
0xffffffff jited:1 86 PASS
[   26.464833] test_bpf: #156 ALU64_AND_K: 0x0000ffffffff0000 & 0x0 =
0x0000ffff00000000 jited:1 100 PASS
[   26.466244] test_bpf: #157 ALU64_AND_K: 0x0000ffffffff0000 & -1 =
0x0000ffffffffffff jited:1 126 PASS
[   26.467904] test_bpf: #158 ALU64_AND_K: 0xffffffffffffffff & -1 =
0xffffffffffffffff jited:1 105 PASS
[   26.469357] test_bpf: #159 ALU_OR_X: 1 | 2 = 3 jited:1 71 PASS
[   26.470510] test_bpf: #160 ALU_OR_X: 0x0 | 0xffffffff = 0xffffffff
jited:1 72 PASS
[   26.471626] test_bpf: #161 ALU64_OR_X: 1 | 2 = 3 jited:1 71 PASS
[   26.472684] test_bpf: #162 ALU64_OR_X: 0 | 0xffffffff = 0xffffffff
jited:1 87 PASS
[   26.473892] test_bpf: #163 ALU_OR_K: 1 | 2 = 3 jited:1 94 PASS
[   26.475174] test_bpf: #164 ALU_OR_K: 0 & 0xffffffff = 0xffffffff
jited:1 84 PASS
[   26.476385] test_bpf: #165 ALU64_OR_K: 1 | 2 = 3 jited:1 71 PASS
[   26.477586] test_bpf: #166 ALU64_OR_K: 0 & 0xffffffff = 0xffffffff
jited:1 80 PASS
[   26.478723] test_bpf: #167 ALU64_OR_K: 0x0000ffffffff0000 | 0x0 =
0x0000ffff00000000 jited:1 124 PASS
[   26.480417] test_bpf: #168 ALU64_OR_K: 0x0000ffffffff0000 | -1 =
0xffffffffffffffff jited:1 94 PASS
[   26.481820] test_bpf: #169 ALU64_OR_K: 0x000000000000000 | -1 =
0xffffffffffffffff jited:1 150 PASS
[   26.483952] test_bpf: #170 ALU_XOR_X: 5 ^ 6 = 3 jited:1 72 PASS
[   26.485195] test_bpf: #171 ALU_XOR_X: 0x1 ^ 0xffffffff = 0xfffffffe
jited:1 89 PASS
[   26.486648] test_bpf: #172 ALU64_XOR_X: 5 ^ 6 = 3 jited:1 80 PASS
[   26.488214] test_bpf: #173 ALU64_XOR_X: 1 ^ 0xffffffff = 0xfffffffe
jited:1 71 PASS
[   26.489566] test_bpf: #174 ALU_XOR_K: 5 ^ 6 = 3 jited:1 79 PASS
[   26.490791] test_bpf: #175 ALU_XOR_K: 1 ^ 0xffffffff = 0xfffffffe
jited:1 105 PASS
[   26.492548] test_bpf: #176 ALU64_XOR_K: 5 ^ 6 = 3 jited:1 128 PASS
[   26.494713] test_bpf: #177 ALU64_XOR_K: 1 & 0xffffffff = 0xfffffffe
jited:1 86 PASS
[   26.496072] test_bpf: #178 ALU64_XOR_K: 0x0000ffffffff0000 ^ 0x0 =
0x0000ffffffff0000 jited:1 102 PASS
[   26.497612] test_bpf: #179 ALU64_XOR_K: 0x0000ffffffff0000 ^ -1 =
0xffff00000000ffff jited:1 88 PASS
[   26.498906] test_bpf: #180 ALU64_XOR_K: 0x000000000000000 ^ -1 =
0xffffffffffffffff jited:1 98 PASS
[   26.500256] test_bpf: #181 ALU_LSH_X: 1 << 1 = 2 jited:1 107 PASS
[   26.501668] test_bpf: #182 ALU_LSH_X: 1 << 31 = 0x80000000 jited:1 70 PASS
[   26.502690] test_bpf: #183 ALU64_LSH_X: 1 << 1 = 2 jited:1 100 PASS
[   26.504077] test_bpf: #184 ALU64_LSH_X: 1 << 31 = 0x80000000 jited:1 78 PASS
[   26.505197] test_bpf: #185 ALU_LSH_K: 1 << 1 = 2 jited:1 76 PASS
[   26.506268] test_bpf: #186 ALU_LSH_K: 1 << 31 = 0x80000000 jited:1 71 PASS
[   26.507301] test_bpf: #187 ALU64_LSH_K: 1 << 1 = 2 jited:1 69 PASS
[   26.508374] test_bpf: #188 ALU64_LSH_K: 1 << 31 = 0x80000000 jited:1 78 PASS
[   26.509494] test_bpf: #189 ALU_RSH_X: 2 >> 1 = 1 jited:1 76 PASS
[   26.510665] test_bpf: #190 ALU_RSH_X: 0x80000000 >> 31 = 1 jited:1 77 PASS
[   26.511787] test_bpf: #191 ALU64_RSH_X: 2 >> 1 = 1 jited:1 79 PASS
[   26.513033] test_bpf: #192 ALU64_RSH_X: 0x80000000 >> 31 = 1 jited:1 95 PASS
[   26.514382] test_bpf: #193 ALU_RSH_K: 2 >> 1 = 1 jited:1 80 PASS
[   26.515648] test_bpf: #194 ALU_RSH_K: 0x80000000 >> 31 = 1 jited:1 72 PASS
[   26.516778] test_bpf: #195 ALU64_RSH_K: 2 >> 1 = 1 jited:1 86 PASS
[   26.517971] test_bpf: #196 ALU64_RSH_K: 0x80000000 >> 31 = 1 jited:1 78 PASS
[   26.519188] test_bpf: #197 ALU_ARSH_X: 0xff00ff0000000000 >> 40 =
0xffffffffffff00ff jited:1 90 PASS
[   26.520458] test_bpf: #198 ALU_ARSH_K: 0xff00ff0000000000 >> 40 =
0xffffffffffff00ff jited:1 69 PASS
[   26.521509] test_bpf: #199 ALU_NEG: -(3) = -3 jited:1 79 PASS
[   26.522692] test_bpf: #200 ALU_NEG: -(-3) = 3 jited:1 101 PASS
[   26.524066] test_bpf: #201 ALU64_NEG: -(3) = -3 jited:1 69 PASS
[   26.525152] test_bpf: #202 ALU64_NEG: -(-3) = 3 jited:1 69 PASS
[   26.526264] test_bpf: #203 ALU_END_FROM_BE 16: 0x0123456789abcdef
-> 0xcdef jited:1 112 PASS
[   26.527879] test_bpf: #204 ALU_END_FROM_BE 32: 0x0123456789abcdef
-> 0x89abcdef jited:1 75 PASS
[   26.529323] test_bpf: #205 ALU_END_FROM_BE 64: 0x0123456789abcdef
-> 0x89abcdef jited:1 88 PASS
[   26.530801] test_bpf: #206 ALU_END_FROM_LE 16: 0x0123456789abcdef
-> 0xefcd jited:1 103 PASS
[   26.532789] test_bpf: #207 ALU_END_FROM_LE 32: 0x0123456789abcdef
-> 0xefcdab89 jited:1 121 PASS
[   26.534881] test_bpf: #208 ALU_END_FROM_LE 64: 0x0123456789abcdef
-> 0x67452301 jited:1 74 PASS
[   26.536388] test_bpf: #209 ST_MEM_B: Store/Load byte: max negative
jited:1 139 PASS
[   26.538618] test_bpf: #210 ST_MEM_B: Store/Load byte: max positive
jited:1 93 PASS
[   26.540104] test_bpf: #211 STX_MEM_B: Store/Load byte: max negative
jited:1 87 PASS
[   26.541494] test_bpf: #212 ST_MEM_H: Store/Load half word: max
negative jited:1 104 PASS
[   26.543038] test_bpf: #213 ST_MEM_H: Store/Load half word: max
positive jited:1 111 PASS
[   26.544554] test_bpf: #214 STX_MEM_H: Store/Load half word: max
negative jited:1 92 PASS
[   26.545885] test_bpf: #215 ST_MEM_W: Store/Load word: max negative
jited:1 124 PASS
[   26.547523] test_bpf: #216 ST_MEM_W: Store/Load word: max positive
jited:1 83 PASS
[   26.548753] test_bpf: #217 STX_MEM_W: Store/Load word: max negative
jited:1 87 PASS
[   26.550001] test_bpf: #218 ST_MEM_DW: Store/Load double word: max
negative jited:1 91 PASS
[   26.551660] test_bpf: #219 ST_MEM_DW: Store/Load double word: max
negative 2 jited:1 117 PASS
[   26.553320] test_bpf: #220 ST_MEM_DW: Store/Load double word: max
positive jited:1 103 PASS
[   26.554733] test_bpf: #221 STX_MEM_DW: Store/Load double word: max
negative jited:1 85 PASS
[   26.555984] test_bpf: #222 STX_XADD_W: Test: 0x12 + 0x10 = 0x22
jited:0 289 PASS
[   26.559204] test_bpf: #223 STX_XADD_W: Test side-effects, r10: 0x12
+ 0x10 = 0x22 jited:0 PASS
[   26.559438] test_bpf: #224 STX_XADD_W: Test side-effects, r0: 0x12
+ 0x10 = 0x22 jited:0 242 PASS
[   26.562189] test_bpf: #225 STX_XADD_W: X + 1 + 1 + 1 + ... jited:0
141847 PASS
[   27.981183] test_bpf: #226 STX_XADD_DW: Test: 0x12 + 0x10 = 0x22
jited:0 374 PASS
[   27.985739] test_bpf: #227 STX_XADD_DW: Test side-effects, r10:
0x12 + 0x10 = 0x22 jited:0 PASS
[   27.985990] test_bpf: #228 STX_XADD_DW: Test side-effects, r0: 0x12
+ 0x10 = 0x22 jited:0 274 PASS
[   27.989010] test_bpf: #229 STX_XADD_DW: X + 1 + 1 + 1 + ... jited:0
340041 PASS
[   31.389811] test_bpf: #230 JMP_EXIT jited:1 73 PASS
[   31.391325] test_bpf: #231 JMP_JA: Unconditional jump: if (true)
return 1 jited:1 90 PASS
[   31.392672] test_bpf: #232 JMP_JSGT_K: Signed jump: if (-1 > -2)
return 1 jited:1 101 PASS
[   31.394242] test_bpf: #233 JMP_JSGT_K: Signed jump: if (-1 > -1)
return 0 jited:1 76 PASS
[   31.395380] test_bpf: #234 JMP_JSGE_K: Signed jump: if (-1 >= -2)
return 1 jited:1 83 PASS
[   31.396628] test_bpf: #235 JMP_JSGE_K: Signed jump: if (-1 >= -1)
return 1 jited:1 80 PASS
[   31.397766] test_bpf: #236 JMP_JGT_K: if (3 > 2) return 1 jited:1 79 PASS
[   31.398935] test_bpf: #237 JMP_JGT_K: Unsigned jump: if (-1 > 1)
return 1 jited:1 124 PASS
[   31.400772] test_bpf: #238 JMP_JGE_K: if (3 >= 2) return 1 jited:1 181 PASS
[   31.403241] test_bpf: #239 JMP_JGT_K: if (3 > 2) return 1 (jump
backwards) jited:1 97 PASS
[   31.404772] test_bpf: #240 JMP_JGE_K: if (3 >= 3) return 1 jited:1 80 PASS
[   31.405965] test_bpf: #241 JMP_JNE_K: if (3 != 2) return 1 jited:1 79 PASS
[   31.407146] test_bpf: #242 JMP_JEQ_K: if (3 == 3) return 1 jited:1 88 PASS
[   31.408357] test_bpf: #243 JMP_JSET_K: if (0x3 & 0x2) return 1
jited:1 115 PASS
[   31.409855] test_bpf: #244 JMP_JSET_K: if (0x3 & 0xffffffff) return
1 jited:1 89 PASS
[   31.411190] test_bpf: #245 JMP_JSGT_X: Signed jump: if (-1 > -2)
return 1 jited:1 93 PASS
[   31.412513] test_bpf: #246 JMP_JSGT_X: Signed jump: if (-1 > -1)
return 0 jited:1 90 PASS
[   31.413820] test_bpf: #247 JMP_JSGE_X: Signed jump: if (-1 >= -2)
return 1 jited:1 93 PASS
[   31.415252] test_bpf: #248 JMP_JSGE_X: Signed jump: if (-1 >= -1)
return 1 jited:1 94 PASS
[   31.416629] test_bpf: #249 JMP_JGT_X: if (3 > 2) return 1 jited:1 88 PASS
[   31.417834] test_bpf: #250 JMP_JGT_X: Unsigned jump: if (-1 > 1)
return 1 jited:1 77 PASS
[   31.419077] test_bpf: #251 JMP_JGE_X: if (3 >= 2) return 1 jited:1 95 PASS
[   31.420402] test_bpf: #252 JMP_JGE_X: if (3 >= 3) return 1 jited:1 97 PASS
[   31.421841] test_bpf: #253 JMP_JGE_X: ldimm64 test 1 jited:1 110 PASS
[   31.423894] test_bpf: #254 JMP_JGE_X: ldimm64 test 2 jited:1 94 PASS
[   31.425370] test_bpf: #255 JMP_JGE_X: ldimm64 test 3 jited:1 107 PASS
[   31.427259] test_bpf: #256 JMP_JNE_X: if (3 != 2) return 1 jited:1 101 PASS
[   31.428931] test_bpf: #257 JMP_JEQ_X: if (3 == 3) return 1 jited:1 94 PASS
[   31.430449] test_bpf: #258 JMP_JSET_X: if (0x3 & 0x2) return 1
jited:1 96 PASS
[   31.431873] test_bpf: #259 JMP_JSET_X: if (0x3 & 0xffffffff) return
1 jited:1 217 PASS
[   31.434897] test_bpf: #260 JMP_JA: Jump, gap, jump, ... jited:1 145 PASS
[   31.437097] test_bpf: #261 BPF_MAXINSNS: Maximum possible literals
jited:1 184 PASS
[   31.460982] test_bpf: #262 BPF_MAXINSNS: Single literal jited:1 250 PASS
[   31.487721] test_bpf: #263 BPF_MAXINSNS: Run/add until end jited:1 6762 PASS
[   31.569308] test_bpf: #264 BPF_MAXINSNS: Too many instructions PASS
[   31.569438] test_bpf: #265 BPF_MAXINSNS: Very long jump jited:1 141 PASS
[   31.585479] test_bpf: #266 BPF_MAXINSNS: Ctx heavy transformations
jited:1 31891 25898 PASS
[   32.183199] test_bpf: #267 BPF_MAXINSNS: Call heavy transformations
jited:0 822248 831950 PASS
[   48.732702] test_bpf: #268 BPF_MAXINSNS: Jump heavy test jited:1 136555 PASS
[   50.117439] test_bpf: #269 BPF_MAXINSNS: Very long jump backwards
jited:1 168 PASS
[   50.127426] test_bpf: #270 BPF_MAXINSNS: Edge hopping nuthouse
jited:1 255760 PASS
[   52.690619] test_bpf: #271 BPF_MAXINSNS: Jump, gap, jump, ...
jited:1 1146 PASS
[   52.724995] test_bpf: #272 BPF_MAXINSNS: ld_abs+get_processor_id
jited:0 562650 PASS
[   58.361997] test_bpf: #273 BPF_MAXINSNS: ld_abs+vlan_push/pop
jited:0 527825 PASS
[   63.641315] test_bpf: #274 LD_IND byte frag jited:1 649 PASS
[   63.649443] test_bpf: #275 LD_IND halfword frag jited:1 640 PASS
[   63.656527] test_bpf: #276 LD_IND word frag jited:1 668 PASS
[   63.664376] test_bpf: #277 LD_IND halfword mixed head/frag jited:1 990 PASS
[   63.675745] test_bpf: #278 LD_IND word mixed head/frag jited:1 971 PASS
[   63.686341] test_bpf: #279 LD_ABS byte frag jited:1 778 PASS
[   63.694965] test_bpf: #280 LD_ABS halfword frag jited:1 982 PASS
[   63.705562] test_bpf: #281 LD_ABS word frag jited:1 737 PASS
[   63.714005] test_bpf: #282 LD_ABS halfword mixed head/frag jited:1 997 PASS
[   63.724868] test_bpf: #283 LD_ABS word mixed head/frag jited:1 1037 PASS
[   63.736399] test_bpf: #284 LD_IND byte default X jited:1 270 PASS
[   63.740296] test_bpf: #285 LD_IND byte positive offset jited:1 214 PASS
[   63.743487] test_bpf: #286 LD_IND byte negative offset jited:1 251 PASS
[   63.747173] test_bpf: #287 LD_IND halfword positive offset jited:1 191 PASS
[   63.749669] test_bpf: #288 LD_IND halfword negative offset jited:1 188 PASS
[   63.752163] test_bpf: #289 LD_IND halfword unaligned jited:1 212 PASS
[   63.754834] test_bpf: #290 LD_IND word positive offset jited:1 187 PASS
[   63.757257] test_bpf: #291 LD_IND word negative offset jited:1 180 PASS
[   63.759764] test_bpf: #292 LD_IND word unaligned (addr & 3 == 2)
jited:1 211 PASS
[   63.762621] test_bpf: #293 LD_IND word unaligned (addr & 3 == 1)
jited:1 276 PASS
[   63.766332] test_bpf: #294 LD_IND word unaligned (addr & 3 == 3)
jited:1 270 PASS
[   63.769931] test_bpf: #295 LD_ABS byte jited:1 253 PASS
[   63.773492] test_bpf: #296 LD_ABS halfword jited:1 251 PASS
[   63.777622] test_bpf: #297 LD_ABS halfword unaligned jited:1 259 PASS
[   63.781554] test_bpf: #298 LD_ABS word jited:1 216 PASS
[   63.784630] test_bpf: #299 LD_ABS word unaligned (addr & 3 == 2)
jited:1 198 PASS
[   63.787174] test_bpf: #300 LD_ABS word unaligned (addr & 3 == 1)
jited:1 177 PASS
[   63.789367] test_bpf: #301 LD_ABS word unaligned (addr & 3 == 3)
jited:1 235 PASS
[   63.792235] test_bpf: #302 ADD default X jited:1 85 PASS
[   63.793953] test_bpf: #303 ADD default A jited:1 87 PASS
[   63.795439] test_bpf: #304 SUB default X jited:1 113 PASS
[   63.797128] test_bpf: #305 SUB default A jited:1 94 PASS
[   63.798801] test_bpf: #306 MUL default X jited:1 95 PASS
[   63.800387] test_bpf: #307 MUL default A jited:1 83 PASS
[   63.801704] test_bpf: #308 DIV default X jited:1 100 PASS
[   63.803305] test_bpf: #309 DIV default A jited:1 216 PASS
[   63.806105] test_bpf: #310 MOD default X jited:1 94 PASS
[   63.807447] test_bpf: #311 MOD default A jited:1 270 PASS
[   63.810667] test_bpf: #312 JMP EQ default A jited:1 94 PASS
[   63.812321] test_bpf: #313 JMP EQ default X jited:1 163 PASS
[   63.814754] test_bpf: Summary: 314 PASSED, 0 FAILED, [278/306 JIT'ed]

Let me know if you need more information.

Best,
Shubham Bansal


On Tue, May 16, 2017 at 1:25 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 05/13/2017 11:38 PM, Shubham Bansal wrote:
>>
>> Finally finished testing.
>>
>> "test_bpf: Summary: 314 PASSED, 0 FAILED, [274/306 JIT'ed]"
>
>
> What are the missing pieces and how is the performance compared
> to the interpreter?
>
> Thanks,
> Daniel
