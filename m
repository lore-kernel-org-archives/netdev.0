From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: Re: arch: arm: bpf: Converting cBPF to eBPF for arm 32 bit
Date: Mon, 22 May 2017 22:34:41 +0530
Message-ID: <CAHgaXd+dTEKyPbkB6oFpLa3z0ygkxK1dMT8R55iYjvsU=GO3Wg@mail.gmail.com>
References: <CAHgaXdKsO2xoKYp7g91g+n+d_1KHSSByLjzBB-WjVXSjhB7qxw@mail.gmail.com>
 <20170510.212952.1440495072777358778.davem@davemloft.net> <CAHgaXdK8LEEUPm4jTRRzCnjwdWAauHmmB=caZsSFY8MmStH89Q@mail.gmail.com>
 <20170510.215218.2185526627014393313.davem@davemloft.net> <CAHgaXdKZ_v+iO7uqEDx7PA7D+xcp1FngGvJ1SRSsGXNQ-iWWDQ@mail.gmail.com>
 <CAHgaXdLJoVUXXGTYs7FYXay5wx=sA-O+=dYhX+r7AQT7vSNfGQ@mail.gmail.com>
 <CAGXu5j+2q4Wwfhuk_DnDaV894A9ZOD=A_AvAU_OZG6KQv0_KMg@mail.gmail.com>
 <CAHgaXdL7GcVzs+ANPke_NywhcgHbe_fzi1sTDEy+Ni1-o82GYQ@mail.gmail.com>
 <591A07A1.1030006@iogearbox.net> <CAHgaXdKKbRVSpX-036TXpV5z=1=QCnPoku0+CeHxHco8-aasPQ@mail.gmail.com>
 <5922E11C.4070307@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kees Cook <keescook@chromium.org>, David Miller <davem@davemloft.net>,
	Mircea Gherzan <mgherzan@gmail.com>, Network Development <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, ast@fb.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <kernel-hardening-return-7970-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <5922E11C.4070307@iogearbox.net>
List-Id: netdev.vger.kernel.org

Hi Daniel,

Here are the benchmarks.

1) Interpreter:

[root@vexpress modules]# insmod test_bpf.ko
[   37.244999] test_bpf: #0 TAX jited:0 757 645 650 PASS
[   37.272577] test_bpf: #1 TXA jited:0 366 334 336 PASS
[   37.283507] test_bpf: #2 ADD_SUB_MUL_K jited:0 543 PASS
[   37.289542] test_bpf: #3 DIV_MOD_KX jited:0 1509 PASS
[   37.305374] test_bpf: #4 AND_OR_LSH_K jited:0 539 559 PASS
[   37.317209] test_bpf: #5 LD_IMM_0 jited:0 412 PASS
[   37.321820] test_bpf: #6 LD_IND jited:0 428 376 389 PASS
[   37.334327] test_bpf: #7 LD_ABS jited:0 509 405 358 PASS
[   37.350596] test_bpf: #8 LD_ABS_LL jited:0 542 783 PASS
[   37.364340] test_bpf: #9 LD_IND_LL jited:0 524 496 723 PASS
[   37.382352] test_bpf: #10 LD_ABS_NET jited:0 527 545 PASS
[   37.393642] test_bpf: #11 LD_IND_NET jited:0 650 495 647 PASS
[   37.412228] test_bpf: #12 LD_PKTTYPE jited:0 686 901 PASS
[   37.428818] test_bpf: #13 LD_MARK jited:0 305 291 PASS
[   37.435349] test_bpf: #14 LD_RXHASH jited:0 257 259 PASS
[   37.440850] test_bpf: #15 LD_QUEUE jited:0 255 254 PASS
[   37.446254] test_bpf: #16 LD_PROTOCOL jited:0 593 603 PASS
[   37.458570] test_bpf: #17 LD_VLAN_TAG jited:0 288 292 PASS
[   37.464821] test_bpf: #18 LD_VLAN_TAG_PRESENT jited:0 335 421 PASS
[   37.472817] test_bpf: #19 LD_IFINDEX jited:0 8568 606 PASS
[   37.565163] test_bpf: #20 LD_HATYPE jited:0 618 695 PASS
[   37.579457] test_bpf: #21 LD_CPU jited:0 1200 1172 PASS
[   37.604424] test_bpf: #22 LD_NLATTR jited:0 979 1124 PASS
[   37.626345] test_bpf: #23 LD_NLATTR_NEST jited:0 12232 3593 PASS
[   37.785251] test_bpf: #24 LD_PAYLOAD_OFF jited:0 3697 4834 PASS
[   37.871224] test_bpf: #25 LD_ANC_XOR jited:0 314 344 PASS
[   37.878210] test_bpf: #26 SPILL_FILL jited:0 757 850 903 PASS
[   37.903954] test_bpf: #27 JEQ jited:0 380 420 426 PASS
[   37.916756] test_bpf: #28 JGT jited:0 376 467 448 PASS
[   37.930276] test_bpf: #29 JGE jited:0 446 590 498 PASS
[   37.946729] test_bpf: #30 JSET jited:0 571 787 1003 PASS
[   37.970896] test_bpf: #31 tcpdump port 22 jited:0 358 1079 1190 PASS
[   37.997814] test_bpf: #32 tcpdump complex jited:0 319 1061 2324 PASS
[   38.035596] test_bpf: #33 RET_A jited:0 253 249 PASS
[   38.041262] test_bpf: #34 INT: ADD trivial jited:0 414 PASS
[   38.045777] test_bpf: #35 INT: MUL_X jited:0 336 PASS
[   38.049402] test_bpf: #36 INT: MUL_X2 jited:0 431 PASS
[   38.054178] test_bpf: #37 INT: MUL32_X jited:0 523 PASS
[   38.059902] test_bpf: #38 INT: ADD 64-bit jited:0 5263 PASS
[   38.113069] test_bpf: #39 INT: ADD 32-bit jited:0 4127 PASS
[   38.154754] test_bpf: #40 INT: SUB jited:0 4218 PASS
[   38.197294] test_bpf: #41 INT: XOR jited:0 2252 PASS
[   38.220159] test_bpf: #42 INT: MUL jited:0 1986 PASS
[   38.240410] test_bpf: #43 MOV REG64 jited:0 1103 PASS
[   38.251796] test_bpf: #44 MOV REG32 jited:0 1140 PASS
[   38.263614] test_bpf: #45 LD IMM64 jited:0 1182 PASS
[   38.276031] test_bpf: #46 INT: ALU MIX jited:0 1068 PASS
[   38.287319] test_bpf: #47 INT: shifts by register jited:0 1125 PASS
[   38.298913] test_bpf: #48 INT: DIV + ABS jited:0 570 850 PASS
[   38.313745] test_bpf: #49 INT: DIV by zero jited:0 350 305 PASS
[   38.320829] test_bpf: #50 check: missing ret PASS
[   38.321186] test_bpf: #51 check: div_k_0 PASS
[   38.321350] test_bpf: #52 check: unknown insn PASS
[   38.321492] test_bpf: #53 check: out of range spill/fill PASS
[   38.321665] test_bpf: #54 JUMPS + HOLES jited:0 863 PASS
[   38.330763] test_bpf: #55 check: RET X PASS
[   38.331060] test_bpf: #56 check: LDX + RET X PASS
[   38.331292] test_bpf: #57 M[]: alt STX + LDX jited:0 3990 PASS
[   38.373667] test_bpf: #58 M[]: full STX + full LDX jited:0 2819 PASS
[   38.410225] test_bpf: #59 check: SKF_AD_MAX PASS
[   38.410461] test_bpf: #60 LD [SKF_AD_OFF-1] jited:0 313 PASS
[   38.413785] test_bpf: #61 load 64-bit immediate jited:0 579 PASS
[   38.419764] test_bpf: #62 nmap reduced jited:0 1860 PASS
[   38.439016] test_bpf: #63 ALU_MOV_X: dst = 2 jited:0 249 PASS
[   38.441990] test_bpf: #64 ALU_MOV_X: dst = 4294967295 jited:0 264 PASS
[   38.445000] test_bpf: #65 ALU64_MOV_X: dst = 2 jited:0 229 PASS
[   38.447602] test_bpf: #66 ALU64_MOV_X: dst = 4294967295 jited:0 213 PASS
[   38.450011] test_bpf: #67 ALU_MOV_K: dst = 2 jited:0 167 PASS
[   38.451963] test_bpf: #68 ALU_MOV_K: dst = 4294967295 jited:0 149 PASS
[   38.453694] test_bpf: #69 ALU_MOV_K: 0x0000ffffffff0000 =
0x00000000ffffffff jited:0 358 PASS
[   38.457572] test_bpf: #70 ALU64_MOV_K: dst = 2 jited:0 158 PASS
[   38.459546] test_bpf: #71 ALU64_MOV_K: dst = 2147483647 jited:0 156 PASS
[   38.461364] test_bpf: #72 ALU64_OR_K: dst = 0x0 jited:0 306 PASS
[   38.464652] test_bpf: #73 ALU64_MOV_K: dst = -1 jited:0 327 PASS
[   38.468154] test_bpf: #74 ALU_ADD_X: 1 + 2 = 3 jited:0 212 PASS
[   38.470551] test_bpf: #75 ALU_ADD_X: 1 + 4294967294 = 4294967295
jited:0 231 PASS
[   38.473187] test_bpf: #76 ALU_ADD_X: 2 + 4294967294 = 0 jited:0 309 PASS
[   38.476618] test_bpf: #77 ALU64_ADD_X: 1 + 2 = 3 jited:0 280 PASS
[   38.479675] test_bpf: #78 ALU64_ADD_X: 1 + 4294967294 = 4294967295
jited:0 286 PASS
[   38.482755] test_bpf: #79 ALU64_ADD_X: 2 + 4294967294 = 4294967296
jited:0 460 PASS
[   38.487670] test_bpf: #80 ALU_ADD_K: 1 + 2 = 3 jited:0 210 PASS
[   38.490042] test_bpf: #81 ALU_ADD_K: 3 + 0 = 3 jited:0 208 PASS
[   38.492331] test_bpf: #82 ALU_ADD_K: 1 + 4294967294 = 4294967295
jited:0 205 PASS
[   38.494604] test_bpf: #83 ALU_ADD_K: 4294967294 + 2 = 0 jited:0 323 PASS
[   38.498071] test_bpf: #84 ALU_ADD_K: 0 + (-1) = 0x00000000ffffffff
jited:0 338 PASS
[   38.501674] test_bpf: #85 ALU_ADD_K: 0 + 0xffff = 0xffff jited:0 347 PASS
[   38.505355] test_bpf: #86 ALU_ADD_K: 0 + 0x7fffffff = 0x7fffffff
jited:0 360 PASS
[   38.509197] test_bpf: #87 ALU_ADD_K: 0 + 0x80000000 = 0x80000000
jited:0 345 PASS
[   38.512873] test_bpf: #88 ALU_ADD_K: 0 + 0x80008000 = 0x80008000
jited:0 377 PASS
[   38.516924] test_bpf: #89 ALU64_ADD_K: 1 + 2 = 3 jited:0 184 PASS
[   38.519053] test_bpf: #90 ALU64_ADD_K: 3 + 0 = 3 jited:0 185 PASS
[   38.521246] test_bpf: #91 ALU64_ADD_K: 1 + 2147483646 = 2147483647
jited:0 186 PASS
[   38.523414] test_bpf: #92 ALU64_ADD_K: 4294967294 + 2 = 4294967296
jited:0 353 PASS
[   38.527276] test_bpf: #93 ALU64_ADD_K: 2147483646 + -2147483647 =
-1 jited:0 182 PASS
[   38.529353] test_bpf: #94 ALU64_ADD_K: 1 + 0 = 1 jited:0 311 PASS
[   38.532680] test_bpf: #95 ALU64_ADD_K: 0 + (-1) =
0xffffffffffffffff jited:0 339 PASS
[   38.536308] test_bpf: #96 ALU64_ADD_K: 0 + 0xffff = 0xffff jited:0 310 PASS
[   38.539652] test_bpf: #97 ALU64_ADD_K: 0 + 0x7fffffff = 0x7fffffff
jited:0 313 PASS
[   38.543022] test_bpf: #98 ALU64_ADD_K: 0 + 0x80000000 =
0xffffffff80000000 jited:0 340 PASS
[   38.546651] test_bpf: #99 ALU_ADD_K: 0 + 0x80008000 =
0xffffffff80008000 jited:0 311 PASS
[   38.549994] test_bpf: #100 ALU_SUB_X: 3 - 1 = 2 jited:0 213 PASS
[   38.552326] test_bpf: #101 ALU_SUB_X: 4294967295 - 4294967294 = 1
jited:0 212 PASS
[   38.554661] test_bpf: #102 ALU64_SUB_X: 3 - 1 = 2 jited:0 237 PASS
[   38.557278] test_bpf: #103 ALU64_SUB_X: 4294967295 - 4294967294 = 1
jited:0 221 PASS
[   38.559713] test_bpf: #104 ALU_SUB_K: 3 - 1 = 2 jited:0 177 PASS
[   38.561682] test_bpf: #105 ALU_SUB_K: 3 - 0 = 3 jited:0 179 PASS
[   38.563692] test_bpf: #106 ALU_SUB_K: 4294967295 - 4294967294 = 1
jited:0 195 PASS
[   38.565891] test_bpf: #107 ALU64_SUB_K: 3 - 1 = 2 jited:0 183 PASS
[   38.567926] test_bpf: #108 ALU64_SUB_K: 3 - 0 = 3 jited:0 177 PASS
[   38.569901] test_bpf: #109 ALU64_SUB_K: 4294967294 - 4294967295 =
-1 jited:0 181 PASS
[   38.571925] test_bpf: #110 ALU64_ADD_K: 2147483646 - 2147483647 =
-1 jited:0 177 PASS
[   38.573910] test_bpf: #111 ALU_MUL_X: 2 * 3 = 6 jited:0 241 PASS
[   38.576535] test_bpf: #112 ALU_MUL_X: 2 * 0x7FFFFFF8 = 0xFFFFFFF0
jited:0 220 PASS
[   38.578948] test_bpf: #113 ALU_MUL_X: -1 * -1 = 1 jited:0 224 PASS
[   38.581387] test_bpf: #114 ALU64_MUL_X: 2 * 3 = 6 jited:0 213 PASS
[   38.583715] test_bpf: #115 ALU64_MUL_X: 1 * 2147483647 = 2147483647
jited:0 230 PASS
[   38.586253] test_bpf: #116 ALU_MUL_K: 2 * 3 = 6 jited:0 191 PASS
[   38.588392] test_bpf: #117 ALU_MUL_K: 3 * 1 = 3 jited:0 189 PASS
[   38.590487] test_bpf: #118 ALU_MUL_K: 2 * 0x7FFFFFF8 = 0xFFFFFFF0
jited:0 192 PASS
[   38.592616] test_bpf: #119 ALU_MUL_K: 1 * (-1) = 0x00000000ffffffff
jited:0 333 PASS
[   38.596172] test_bpf: #120 ALU64_MUL_K: 2 * 3 = 6 jited:0 185 PASS
[   38.598224] test_bpf: #121 ALU64_MUL_K: 3 * 1 = 3 jited:0 185 PASS
[   38.600287] test_bpf: #122 ALU64_MUL_K: 1 * 2147483647 = 2147483647
jited:0 184 PASS
[   38.602369] test_bpf: #123 ALU64_MUL_K: 1 * -2147483647 =
-2147483647 jited:0 183 PASS
[   38.604421] test_bpf: #124 ALU64_MUL_K: 1 * (-1) =
0xffffffffffffffff jited:0 336 PASS
[   38.608002] test_bpf: #125 ALU_DIV_X: 6 / 2 = 3 jited:0 316 PASS
[   38.611394] test_bpf: #126 ALU_DIV_X: 4294967295 / 4294967295 = 1
jited:0 315 PASS
[   38.614753] test_bpf: #127 ALU64_DIV_X: 6 / 2 = 3 jited:0 439 PASS
[   38.619370] test_bpf: #128 ALU64_DIV_X: 2147483647 / 2147483647 = 1
jited:0 420 PASS
[   38.623844] test_bpf: #129 ALU64_DIV_X: 0xffffffffffffffff / (-1) =
0x0000000000000001 jited:0 604 PASS
[   38.630156] test_bpf: #130 ALU_DIV_K: 6 / 2 = 3 jited:0 249 PASS
[   38.632858] test_bpf: #131 ALU_DIV_K: 3 / 1 = 3 jited:0 240 PASS
[   38.635647] test_bpf: #132 ALU_DIV_K: 4294967295 / 4294967295 = 1
jited:0 254 PASS
[   38.638408] test_bpf: #133 ALU_DIV_K: 0xffffffffffffffff / (-1) =
0x1 jited:0 379 PASS
[   38.642450] test_bpf: #134 ALU64_DIV_K: 6 / 2 = 3 jited:0 346 PASS
[   38.646123] test_bpf: #135 ALU64_DIV_K: 3 / 1 = 3 jited:0 323 PASS
[   38.649558] test_bpf: #136 ALU64_DIV_K: 2147483647 / 2147483647 = 1
jited:0 329 PASS
[   38.653061] test_bpf: #137 ALU64_DIV_K: 0xffffffffffffffff / (-1) =
0x0000000000000001 jited:0 477 PASS
[   38.658065] test_bpf: #138 ALU_MOD_X: 3 % 2 = 1 jited:0 421 PASS
[   38.662580] test_bpf: #139 ALU_MOD_X: 4294967295 % 4294967293 = 2
jited:0 453 PASS
[   38.667414] test_bpf: #140 ALU64_MOD_X: 3 % 2 = 1 jited:0 553 PASS
[   38.673235] test_bpf: #141 ALU64_MOD_X: 2147483647 % 2147483645 = 2
jited:0 583 PASS
[   38.679343] test_bpf: #142 ALU_MOD_K: 3 % 2 = 1 jited:0 380 PASS
[   38.683374] test_bpf: #143 ALU_MOD_K: 3 % 1 = 0 jited:0 PASS
[   38.683586] test_bpf: #144 ALU_MOD_K: 4294967295 % 4294967293 = 2
jited:0 467 PASS
[   38.688672] test_bpf: #145 ALU64_MOD_K: 3 % 2 = 1 jited:0 492 PASS
[   38.694058] test_bpf: #146 ALU64_MOD_K: 3 % 1 = 0 jited:0 PASS
[   38.694359] test_bpf: #147 ALU64_MOD_K: 2147483647 % 2147483645 = 2
jited:0 571 PASS
[   38.700389] test_bpf: #148 ALU_AND_X: 3 & 2 = 2 jited:0 225 PASS
[   38.702952] test_bpf: #149 ALU_AND_X: 0xffffffff & 0xffffffff =
0xffffffff jited:0 261 PASS
[   38.705982] test_bpf: #150 ALU64_AND_X: 3 & 2 = 2 jited:0 273 PASS
[   38.709194] test_bpf: #151 ALU64_AND_X: 0xffffffff & 0xffffffff =
0xffffffff jited:0 251 PASS
[   38.712213] test_bpf: #152 ALU_AND_K: 3 & 2 = 2 jited:0 201 PASS
[   38.714638] test_bpf: #153 ALU_AND_K: 0xffffffff & 0xffffffff =
0xffffffff jited:0 240 PASS
[   38.717477] test_bpf: #154 ALU64_AND_K: 3 & 2 = 2 jited:0 209 PASS
[   38.720125] test_bpf: #155 ALU64_AND_K: 0xffffffff & 0xffffffff =
0xffffffff jited:0 319 PASS
[   38.724356] test_bpf: #156 ALU64_AND_K: 0x0000ffffffff0000 & 0x0 =
0x0000ffff00000000 jited:0 384 PASS
[   38.729293] test_bpf: #157 ALU64_AND_K: 0x0000ffffffff0000 & -1 =
0x0000ffffffffffff jited:0 367 PASS
[   38.733598] test_bpf: #158 ALU64_AND_K: 0xffffffffffffffff & -1 =
0xffffffffffffffff jited:0 375 PASS
[   38.737966] test_bpf: #159 ALU_OR_X: 1 | 2 = 3 jited:0 271 PASS
[   38.741274] test_bpf: #160 ALU_OR_X: 0x0 | 0xffffffff = 0xffffffff
jited:0 280 PASS
[   38.744653] test_bpf: #161 ALU64_OR_X: 1 | 2 = 3 jited:0 253 PASS
[   38.747717] test_bpf: #162 ALU64_OR_X: 0 | 0xffffffff = 0xffffffff
jited:0 263 PASS
[   38.750830] test_bpf: #163 ALU_OR_K: 1 | 2 = 3 jited:0 216 PASS
[   38.753357] test_bpf: #164 ALU_OR_K: 0 & 0xffffffff = 0xffffffff
jited:0 187 PASS
[   38.755553] test_bpf: #165 ALU64_OR_K: 1 | 2 = 3 jited:0 183 PASS
[   38.757693] test_bpf: #166 ALU64_OR_K: 0 & 0xffffffff = 0xffffffff
jited:0 195 PASS
[   38.759975] test_bpf: #167 ALU64_OR_K: 0x0000ffffffff0000 | 0x0 =
0x0000ffff00000000 jited:0 338 PASS
[   38.763728] test_bpf: #168 ALU64_OR_K: 0x0000ffffffff0000 | -1 =
0xffffffffffffffff jited:0 324 PASS
[   38.767311] test_bpf: #169 ALU64_OR_K: 0x000000000000000 | -1 =
0xffffffffffffffff jited:0 309 PASS
[   38.770633] test_bpf: #170 ALU_XOR_X: 5 ^ 6 = 3 jited:0 216 PASS
[   38.776135] test_bpf: #171 ALU_XOR_X: 0x1 ^ 0xffffffff = 0xfffffffe
jited:0 414 PASS
[   38.780950] test_bpf: #172 ALU64_XOR_X: 5 ^ 6 = 3 jited:0 320 PASS
[   38.784540] test_bpf: #173 ALU64_XOR_X: 1 ^ 0xffffffff = 0xfffffffe
jited:0 223 PASS
[   38.787037] test_bpf: #174 ALU_XOR_K: 5 ^ 6 = 3 jited:0 203 PASS
[   38.789359] test_bpf: #175 ALU_XOR_K: 1 ^ 0xffffffff = 0xfffffffe
jited:0 205 PASS
[   38.791707] test_bpf: #176 ALU64_XOR_K: 5 ^ 6 = 3 jited:0 205 PASS
[   38.794045] test_bpf: #177 ALU64_XOR_K: 1 & 0xffffffff = 0xfffffffe
jited:0 186 PASS
[   38.796180] test_bpf: #178 ALU64_XOR_K: 0x0000ffffffff0000 ^ 0x0 =
0x0000ffffffff0000 jited:0 352 PASS
[   38.800050] test_bpf: #179 ALU64_XOR_K: 0x0000ffffffff0000 ^ -1 =
0xffff00000000ffff jited:0 353 PASS
[   38.803970] test_bpf: #180 ALU64_XOR_K: 0x000000000000000 ^ -1 =
0xffffffffffffffff jited:0 362 PASS
[   38.808102] test_bpf: #181 ALU_LSH_X: 1 << 1 = 2 jited:0 211 PASS
[   38.810517] test_bpf: #182 ALU_LSH_X: 1 << 31 = 0x80000000 jited:0 216 PASS
[   38.812957] test_bpf: #183 ALU64_LSH_X: 1 << 1 = 2 jited:0 224 PASS
[   38.815480] test_bpf: #184 ALU64_LSH_X: 1 << 31 = 0x80000000 jited:0 223 PASS
[   38.818057] test_bpf: #185 ALU_LSH_K: 1 << 1 = 2 jited:0 208 PASS
[   38.820559] test_bpf: #186 ALU_LSH_K: 1 << 31 = 0x80000000 jited:0 210 PASS
[   38.823011] test_bpf: #187 ALU64_LSH_K: 1 << 1 = 2 jited:0 211 PASS
[   38.825737] test_bpf: #188 ALU64_LSH_K: 1 << 31 = 0x80000000 jited:0 182 PASS
[   38.828021] test_bpf: #189 ALU_RSH_X: 2 >> 1 = 1 jited:0 226 PASS
[   38.830655] test_bpf: #190 ALU_RSH_X: 0x80000000 >> 31 = 1 jited:0 225 PASS
[   38.833287] test_bpf: #191 ALU64_RSH_X: 2 >> 1 = 1 jited:0 289 PASS
[   38.836535] test_bpf: #192 ALU64_RSH_X: 0x80000000 >> 31 = 1 jited:0 253 PASS
[   38.839501] test_bpf: #193 ALU_RSH_K: 2 >> 1 = 1 jited:0 207 PASS
[   38.842025] test_bpf: #194 ALU_RSH_K: 0x80000000 >> 31 = 1 jited:0 210 PASS
[   38.844570] test_bpf: #195 ALU64_RSH_K: 2 >> 1 = 1 jited:0 232 PASS
[   38.847341] test_bpf: #196 ALU64_RSH_K: 0x80000000 >> 31 = 1 jited:0 208 PASS
[   38.849849] test_bpf: #197 ALU_ARSH_X: 0xff00ff0000000000 >> 40 =
0xffffffffffff00ff jited:0 252 PASS
[   38.852728] test_bpf: #198 ALU_ARSH_K: 0xff00ff0000000000 >> 40 =
0xffffffffffff00ff jited:0 197 PASS
[   38.855165] test_bpf: #199 ALU_NEG: -(3) = -3 jited:0 189 PASS
[   38.857410] test_bpf: #200 ALU_NEG: -(-3) = 3 jited:0 171 PASS
[   38.859380] test_bpf: #201 ALU64_NEG: -(3) = -3 jited:0 179 PASS
[   38.861411] test_bpf: #202 ALU64_NEG: -(-3) = 3 jited:0 180 PASS
[   38.863491] test_bpf: #203 ALU_END_FROM_BE 16: 0x0123456789abcdef
-> 0xcdef jited:0 202 PASS
[   38.865978] test_bpf: #204 ALU_END_FROM_BE 32: 0x0123456789abcdef
-> 0x89abcdef jited:0 368 PASS
[   38.869957] test_bpf: #205 ALU_END_FROM_BE 64: 0x0123456789abcdef
-> 0x89abcdef jited:0 244 PASS
[   38.872708] test_bpf: #206 ALU_END_FROM_LE 16: 0x0123456789abcdef
-> 0xefcd jited:0 274 PASS
[   38.875930] test_bpf: #207 ALU_END_FROM_LE 32: 0x0123456789abcdef
-> 0xefcdab89 jited:0 319 PASS
[   38.879417] test_bpf: #208 ALU_END_FROM_LE 64: 0x0123456789abcdef
-> 0x67452301 jited:0 193 PASS
[   38.881653] test_bpf: #209 ST_MEM_B: Store/Load byte: max negative
jited:0 219 PASS
[   38.884143] test_bpf: #210 ST_MEM_B: Store/Load byte: max positive
jited:0 227 PASS
[   38.886902] test_bpf: #211 STX_MEM_B: Store/Load byte: max negative
jited:0 251 PASS
[   38.889691] test_bpf: #212 ST_MEM_H: Store/Load half word: max
negative jited:0 218 PASS
[   38.892132] test_bpf: #213 ST_MEM_H: Store/Load half word: max
positive jited:0 208 PASS
[   38.894448] test_bpf: #214 STX_MEM_H: Store/Load half word: max
negative jited:0 259 PASS
[   38.897504] test_bpf: #215 ST_MEM_W: Store/Load word: max negative
jited:0 253 PASS
[   38.900355] test_bpf: #216 ST_MEM_W: Store/Load word: max positive
jited:0 244 PASS
[   38.903051] test_bpf: #217 STX_MEM_W: Store/Load word: max negative
jited:0 297 PASS
[   38.906372] test_bpf: #218 ST_MEM_DW: Store/Load double word: max
negative jited:0 257 PASS
[   38.909268] test_bpf: #219 ST_MEM_DW: Store/Load double word: max
negative 2 jited:0 392 PASS
[   38.913520] test_bpf: #220 ST_MEM_DW: Store/Load double word: max
positive jited:0 292 PASS
[   38.916792] test_bpf: #221 STX_MEM_DW: Store/Load double word: max
negative jited:0 259 PASS
[   38.919654] test_bpf: #222 STX_XADD_W: Test: 0x12 + 0x10 = 0x22
jited:0 262 PASS
[   38.922517] test_bpf: #223 STX_XADD_W: Test side-effects, r10: 0x12
+ 0x10 = 0x22 jited:0 PASS
[   38.922764] test_bpf: #224 STX_XADD_W: Test side-effects, r0: 0x12
+ 0x10 = 0x22 jited:0 221 PASS
[   38.925373] test_bpf: #225 STX_XADD_W: X + 1 + 1 + 1 + ... jited:0
142719 PASS
[   40.352892] test_bpf: #226 STX_XADD_DW: Test: 0x12 + 0x10 = 0x22
jited:0 345 PASS
[   40.356940] test_bpf: #227 STX_XADD_DW: Test side-effects, r10:
0x12 + 0x10 = 0x22 jited:0 PASS
[   40.357188] test_bpf: #228 STX_XADD_DW: Test side-effects, r0: 0x12
+ 0x10 = 0x22 jited:0 254 PASS
[   40.359954] test_bpf: #229 STX_XADD_DW: X + 1 + 1 + 1 + ... jited:0
349891 PASS
[   43.859287] test_bpf: #230 JMP_EXIT jited:0 127 PASS
[   43.861346] test_bpf: #231 JMP_JA: Unconditional jump: if (true)
return 1 jited:0 194 PASS
[   43.863538] test_bpf: #232 JMP_JSGT_K: Signed jump: if (-1 > -2)
return 1 jited:0 262 PASS
[   43.866400] test_bpf: #233 JMP_JSGT_K: Signed jump: if (-1 > -1)
return 0 jited:0 249 PASS
[   43.869132] test_bpf: #234 JMP_JSGE_K: Signed jump: if (-1 >= -2)
return 1 jited:0 262 PASS
[   43.872046] test_bpf: #235 JMP_JSGE_K: Signed jump: if (-1 >= -1)
return 1 jited:0 260 PASS
[   43.874890] test_bpf: #236 JMP_JGT_K: if (3 > 2) return 1 jited:0 260 PASS
[   43.877701] test_bpf: #237 JMP_JGT_K: Unsigned jump: if (-1 > 1)
return 1 jited:0 278 PASS
[   43.880801] test_bpf: #238 JMP_JGE_K: if (3 >= 2) return 1 jited:0 255 PASS
[   43.883637] test_bpf: #239 JMP_JGT_K: if (3 > 2) return 1 (jump
backwards) jited:0 321 PASS
[   43.887202] test_bpf: #240 JMP_JGE_K: if (3 >= 3) return 1 jited:0 340 PASS
[   43.891306] test_bpf: #241 JMP_JNE_K: if (3 != 2) return 1 jited:0 310 PASS
[   43.895036] test_bpf: #242 JMP_JEQ_K: if (3 == 3) return 1 jited:0 310 PASS
[   43.898963] test_bpf: #243 JMP_JSET_K: if (0x3 & 0x2) return 1
jited:0 276 PASS
[   43.902034] test_bpf: #244 JMP_JSET_K: if (0x3 & 0xffffffff) return
1 jited:0 312 PASS
[   43.905679] test_bpf: #245 JMP_JSGT_X: Signed jump: if (-1 > -2)
return 1 jited:0 346 PASS
[   43.909500] test_bpf: #246 JMP_JSGT_X: Signed jump: if (-1 > -1)
return 0 jited:0 292 PASS
[   43.912696] test_bpf: #247 JMP_JSGE_X: Signed jump: if (-1 >= -2)
return 1 jited:0 318 PASS
[   43.916115] test_bpf: #248 JMP_JSGE_X: Signed jump: if (-1 >= -1)
return 1 jited:0 287 PASS
[   43.919236] test_bpf: #249 JMP_JGT_X: if (3 > 2) return 1 jited:0 316 PASS
[   43.922749] test_bpf: #250 JMP_JGT_X: Unsigned jump: if (-1 > 1)
return 1 jited:0 400 PASS
[   43.927178] test_bpf: #251 JMP_JGE_X: if (3 >= 2) return 1 jited:0 287 PASS
[   43.930323] test_bpf: #252 JMP_JGE_X: if (3 >= 3) return 1 jited:0 287 PASS
[   43.933432] test_bpf: #253 JMP_JGE_X: ldimm64 test 1 jited:0 323 PASS
[   43.936912] test_bpf: #254 JMP_JGE_X: ldimm64 test 2 jited:0 298 PASS
[   43.940168] test_bpf: #255 JMP_JGE_X: ldimm64 test 3 jited:0 263 PASS
[   43.943062] test_bpf: #256 JMP_JNE_X: if (3 != 2) return 1 jited:0 313 PASS
[   43.946483] test_bpf: #257 JMP_JEQ_X: if (3 == 3) return 1 jited:0 308 PASS
[   43.949817] test_bpf: #258 JMP_JSET_X: if (0x3 & 0x2) return 1
jited:0 359 PASS
[   43.953715] test_bpf: #259 JMP_JSET_X: if (0x3 & 0xffffffff) return
1 jited:0 421 PASS
[   43.958350] test_bpf: #260 JMP_JA: Jump, gap, jump, ... jited:0 309 PASS
[   43.961783] test_bpf: #261 BPF_MAXINSNS: Maximum possible literals
jited:0 251 PASS
[   43.969019] test_bpf: #262 BPF_MAXINSNS: Single literal jited:0 286 PASS
[   43.976250] test_bpf: #263 BPF_MAXINSNS: Run/add until end jited:0
254969 PASS
[   46.530754] test_bpf: #264 BPF_MAXINSNS: Too many instructions PASS
[   46.531227] test_bpf: #265 BPF_MAXINSNS: Very long jump jited:0 284 PASS
[   46.538925] test_bpf: #266 BPF_MAXINSNS: Ctx heavy transformations
jited:0 548311 560800 PASS
[   57.635685] test_bpf: #267 BPF_MAXINSNS: Call heavy transformations
jited:0 949505 881276 PASS
[   75.951893] test_bpf: #268 BPF_MAXINSNS: Jump heavy test jited:0 480796 PASS
[   80.765143] test_bpf: #269 BPF_MAXINSNS: Very long jump backwards
jited:0 193 PASS
[   80.767750] test_bpf: #270 BPF_MAXINSNS: Edge hopping nuthouse
jited:0 114304 PASS
[   81.911103] test_bpf: #271 BPF_MAXINSNS: Jump, gap, jump, ...
jited:0 1884 PASS
[   81.935374] test_bpf: #272 BPF_MAXINSNS: ld_abs+get_processor_id
jited:0 546269 PASS
[   87.405760] test_bpf: #273 BPF_MAXINSNS: ld_abs+vlan_push/pop
jited:0 594906 PASS
[   93.356075] test_bpf: #274 LD_IND byte frag jited:0 695 PASS
[   93.364087] test_bpf: #275 LD_IND halfword frag jited:0 818 PASS
[   93.372861] test_bpf: #276 LD_IND word frag jited:0 837 PASS
[   93.381738] test_bpf: #277 LD_IND halfword mixed head/frag jited:0 1170 PASS
[   93.394096] test_bpf: #278 LD_IND word mixed head/frag jited:0 950 PASS
[   93.404149] test_bpf: #279 LD_ABS byte frag jited:0 953 PASS
[   93.414270] test_bpf: #280 LD_ABS halfword frag jited:0 754 PASS
[   93.422281] test_bpf: #281 LD_ABS word frag jited:0 1133 PASS
[   93.434166] test_bpf: #282 LD_ABS halfword mixed head/frag jited:0 1079 PASS
[   93.445353] test_bpf: #283 LD_ABS word mixed head/frag jited:0 718 PASS
[   93.452901] test_bpf: #284 LD_IND byte default X jited:0 297 PASS
[   93.456118] test_bpf: #285 LD_IND byte positive offset jited:0 300 PASS
[   93.459342] test_bpf: #286 LD_IND byte negative offset jited:0 296 PASS
[   93.462553] test_bpf: #287 LD_IND halfword positive offset jited:0 333 PASS
[   93.466116] test_bpf: #288 LD_IND halfword negative offset jited:0 306 PASS
[   93.469402] test_bpf: #289 LD_IND halfword unaligned jited:0 307 PASS
[   93.472711] test_bpf: #290 LD_IND word positive offset jited:0 337 PASS
[   93.476296] test_bpf: #291 LD_IND word negative offset jited:0 312 PASS
[   93.479676] test_bpf: #292 LD_IND word unaligned (addr & 3 == 2)
jited:0 309 PASS
[   93.482987] test_bpf: #293 LD_IND word unaligned (addr & 3 == 1)
jited:0 335 PASS
[   93.486601] test_bpf: #294 LD_IND word unaligned (addr & 3 == 3)
jited:0 305 PASS
[   93.489878] test_bpf: #295 LD_ABS byte jited:0 269 PASS
[   93.492784] test_bpf: #296 LD_ABS halfword jited:0 294 PASS
[   93.495950] test_bpf: #297 LD_ABS halfword unaligned jited:0 271 PASS
[   93.498895] test_bpf: #298 LD_ABS word jited:0 265 PASS
[   93.501756] test_bpf: #299 LD_ABS word unaligned (addr & 3 == 2)
jited:0 267 PASS
[   93.504667] test_bpf: #300 LD_ABS word unaligned (addr & 3 == 1)
jited:0 269 PASS
[   93.507584] test_bpf: #301 LD_ABS word unaligned (addr & 3 == 3)
jited:0 281 PASS
[   93.510665] test_bpf: #302 ADD default X jited:0 296 PASS
[   93.513830] test_bpf: #303 ADD default A jited:0 309 PASS
[   93.517144] test_bpf: #304 SUB default X jited:0 290 PASS
[   93.520249] test_bpf: #305 SUB default A jited:0 252 PASS
[   93.522974] test_bpf: #306 MUL default X jited:0 322 PASS
[   93.526403] test_bpf: #307 MUL default A jited:0 267 PASS
[   93.529277] test_bpf: #308 DIV default X jited:0 293 PASS
[   93.532414] test_bpf: #309 DIV default A jited:0 336 PASS
[   93.535988] test_bpf: #310 MOD default X jited:0 284 PASS
[   93.539032] test_bpf: #311 MOD default A jited:0 435 PASS
[   93.543608] test_bpf: #312 JMP EQ default A jited:0 352 PASS
[   93.547355] test_bpf: #313 JMP EQ default X jited:0 357 PASS
[   93.551176] test_bpf: Summary: 314 PASSED, 0 FAILED, [0/306 JIT'ed]

2) JIT enabled

[root@vexpress modules]# insmod test_bpf.ko
[   53.785470] test_bpf: #0 TAX jited:1 234 171 195 PASS
[   53.794856] test_bpf: #1 TXA jited:1 81 79 77 PASS
[   53.803927] test_bpf: #2 ADD_SUB_MUL_K jited:1 89 PASS
[   53.805542] test_bpf: #3 DIV_MOD_KX jited:1 939 PASS
[   53.816227] test_bpf: #4 AND_OR_LSH_K jited:1 116 114 PASS
[   53.821088] test_bpf: #5 LD_IMM_0 jited:1 93 PASS
[   53.822900] test_bpf: #6 LD_IND jited:1 371 279 274 PASS
[   53.833030] test_bpf: #7 LD_ABS jited:1 408 402 272 PASS
[   53.844767] test_bpf: #8 LD_ABS_LL jited:1 387 346 PASS
[   53.852730] test_bpf: #9 LD_IND_LL jited:1 239 248 217 PASS
[   53.860410] test_bpf: #10 LD_ABS_NET jited:1 356 332 PASS
[   53.867897] test_bpf: #11 LD_IND_NET jited:1 223 212 320 PASS
[   53.876076] test_bpf: #12 LD_PKTTYPE jited:1 102 90 PASS
[   53.878660] test_bpf: #13 LD_MARK jited:1 80 80 PASS
[   53.880695] test_bpf: #14 LD_RXHASH jited:1 73 71 PASS
[   53.882488] test_bpf: #15 LD_QUEUE jited:1 120 121 PASS
[   53.885266] test_bpf: #16 LD_PROTOCOL jited:1 256 247 PASS
[   53.890918] test_bpf: #17 LD_VLAN_TAG jited:1 82 84 PASS
[   53.893002] test_bpf: #18 LD_VLAN_TAG_PRESENT jited:1 80 77 PASS
[   53.894946] test_bpf: #19 LD_IFINDEX jited:1 87 98 PASS
[   53.897261] test_bpf: #20 LD_HATYPE jited:1 95 90 PASS
[   53.899466] test_bpf: #21 LD_CPU
[   53.899663] bpf_jit: *** NOT YET: opcode 85 ***
[   53.899796] jited:0 722 837 PASS
[   53.915645] test_bpf: #22 LD_NLATTR jited:0 593 659 PASS
[   53.928662] test_bpf: #23 LD_NLATTR_NEST jited:0 2186 2964 PASS
[   53.980966] test_bpf: #24 LD_PAYLOAD_OFF jited:0 3891 5637 PASS
[   54.076878] test_bpf: #25 LD_ANC_XOR jited:1 86 100 PASS
[   54.079241] test_bpf: #26 SPILL_FILL jited:1 131 137 123 PASS
[   54.084092] test_bpf: #27 JEQ jited:1 266 189 216 PASS
[   54.091500] test_bpf: #28 JGT jited:1 301 211 192 PASS
[   54.099467] test_bpf: #29 JGE jited:1 191 200 223 PASS
[   54.106275] test_bpf: #30 JSET jited:1 211 210 214 PASS
[   54.113660] test_bpf: #31 tcpdump port 22 jited:1 314 722 711 PASS
[   54.131943] test_bpf: #32 tcpdump complex jited:1 291 707 1068 PASS
[   54.153409] test_bpf: #33 RET_A jited:1 83 88 PASS
[   54.155617] test_bpf: #34 INT: ADD trivial jited:1 162 PASS
[   54.158387] test_bpf: #35 INT: MUL_X jited:1 176 PASS
[   54.161075] test_bpf: #36 INT: MUL_X2 jited:1 84 PASS
[   54.162483] test_bpf: #37 INT: MUL32_X jited:1 99 PASS
[   54.163849] test_bpf: #38 INT: ADD 64-bit jited:1 1066 PASS
[   54.175468] test_bpf: #39 INT: ADD 32-bit jited:1 666 PASS
[   54.182860] test_bpf: #40 INT: SUB jited:1 3236 PASS
[   54.215932] test_bpf: #41 INT: XOR jited:1 308 PASS
[   54.219704] test_bpf: #42 INT: MUL jited:1 376 PASS
[   54.224452] test_bpf: #43 MOV REG64 jited:1 227 PASS
[   54.227383] test_bpf: #44 MOV REG32 jited:1 171 PASS
[   54.229618] test_bpf: #45 LD IMM64 jited:1 163 PASS
[   54.231875] test_bpf: #46 INT: ALU MIX jited:0 1277 PASS
[   54.245188] test_bpf: #47 INT: shifts by register jited:1 208 PASS
[   54.248151] test_bpf: #48 INT: DIV + ABS jited:1 659 601 PASS
[   54.261395] test_bpf: #49 INT: DIV by zero jited:1 317 169 PASS
[   54.266949] test_bpf: #50 check: missing ret PASS
[   54.267418] test_bpf: #51 check: div_k_0 PASS
[   54.267631] test_bpf: #52 check: unknown insn PASS
[   54.267804] test_bpf: #53 check: out of range spill/fill PASS
[   54.268008] test_bpf: #54 JUMPS + HOLES jited:1 358 PASS
[   54.272201] test_bpf: #55 check: RET X PASS
[   54.273054] test_bpf: #56 check: LDX + RET X PASS
[   54.273226] test_bpf: #57 M[]: alt STX + LDX jited:1 456 PASS
[   54.278359] test_bpf: #58 M[]: full STX + full LDX jited:1 438 PASS
[   54.283300] test_bpf: #59 check: SKF_AD_MAX PASS
[   54.283576] test_bpf: #60 LD [SKF_AD_OFF-1] jited:1 198 PASS
[   54.285812] test_bpf: #61 load 64-bit immediate jited:1 125 PASS
[   54.287556] test_bpf: #62 nmap reduced jited:1 1054 PASS
[   54.298630] test_bpf: #63 ALU_MOV_X: dst = 2 jited:1 81 PASS
[   54.300079] test_bpf: #64 ALU_MOV_X: dst = 4294967295 jited:1 85 PASS
[   54.301462] test_bpf: #65 ALU64_MOV_X: dst = 2 jited:1 96 PASS
[   54.303048] test_bpf: #66 ALU64_MOV_X: dst = 4294967295 jited:1 71 PASS
[   54.304115] test_bpf: #67 ALU_MOV_K: dst = 2 jited:1 70 PASS
[   54.305148] test_bpf: #68 ALU_MOV_K: dst = 4294967295 jited:1 71 PASS
[   54.306222] test_bpf: #69 ALU_MOV_K: 0x0000ffffffff0000 =
0x00000000ffffffff jited:1 97 PASS
[   54.307659] test_bpf: #70 ALU64_MOV_K: dst = 2 jited:1 75 PASS
[   54.308750] test_bpf: #71 ALU64_MOV_K: dst = 2147483647 jited:1 66 PASS
[   54.309773] test_bpf: #72 ALU64_OR_K: dst = 0x0 jited:1 92 PASS
[   54.311093] test_bpf: #73 ALU64_MOV_K: dst = -1 jited:1 94 PASS
[   54.312383] test_bpf: #74 ALU_ADD_X: 1 + 2 = 3 jited:1 66 PASS
[   54.313388] test_bpf: #75 ALU_ADD_X: 1 + 4294967294 = 4294967295
jited:1 66 PASS
[   54.314430] test_bpf: #76 ALU_ADD_X: 2 + 4294967294 = 0 jited:1 87 PASS
[   54.315756] test_bpf: #77 ALU64_ADD_X: 1 + 2 = 3 jited:1 77 PASS
[   54.316892] test_bpf: #78 ALU64_ADD_X: 1 + 4294967294 = 4294967295
jited:1 72 PASS
[   54.318015] test_bpf: #79 ALU64_ADD_X: 2 + 4294967294 = 4294967296
jited:1 79 PASS
[   54.319181] test_bpf: #80 ALU_ADD_K: 1 + 2 = 3 jited:1 75 PASS
[   54.320261] test_bpf: #81 ALU_ADD_K: 3 + 0 = 3 jited:1 71 PASS
[   54.321307] test_bpf: #82 ALU_ADD_K: 1 + 4294967294 = 4294967295
jited:1 67 PASS
[   54.322342] test_bpf: #83 ALU_ADD_K: 4294967294 + 2 = 0 jited:1 82 PASS
[   54.323600] test_bpf: #84 ALU_ADD_K: 0 + (-1) = 0x00000000ffffffff
jited:1 86 PASS
[   54.325898] test_bpf: #85 ALU_ADD_K: 0 + 0xffff = 0xffff jited:1 99 PASS
[   54.327242] test_bpf: #86 ALU_ADD_K: 0 + 0x7fffffff = 0x7fffffff
jited:1 113 PASS
[   54.328684] test_bpf: #87 ALU_ADD_K: 0 + 0x80000000 = 0x80000000
jited:1 123 PASS
[   54.330224] test_bpf: #88 ALU_ADD_K: 0 + 0x80008000 = 0x80008000
jited:1 85 PASS
[   54.331395] test_bpf: #89 ALU64_ADD_K: 1 + 2 = 3 jited:1 66 PASS
[   54.332375] test_bpf: #90 ALU64_ADD_K: 3 + 0 = 3 jited:1 66 PASS
[   54.333381] test_bpf: #91 ALU64_ADD_K: 1 + 2147483646 = 2147483647
jited:1 69 PASS
[   54.334397] test_bpf: #92 ALU64_ADD_K: 4294967294 + 2 = 4294967296
jited:1 109 PASS
[   54.335818] test_bpf: #93 ALU64_ADD_K: 2147483646 + -2147483647 =
-1 jited:1 72 PASS
[   54.336873] test_bpf: #94 ALU64_ADD_K: 1 + 0 = 1 jited:1 126 PASS
[   54.338484] test_bpf: #95 ALU64_ADD_K: 0 + (-1) =
0xffffffffffffffff jited:1 107 PASS
[   54.340100] test_bpf: #96 ALU64_ADD_K: 0 + 0xffff = 0xffff jited:1 98 PASS
[   54.341569] test_bpf: #97 ALU64_ADD_K: 0 + 0x7fffffff = 0x7fffffff
jited:1 87 PASS
[   54.342794] test_bpf: #98 ALU64_ADD_K: 0 + 0x80000000 =
0xffffffff80000000 jited:1 98 PASS
[   54.344142] test_bpf: #99 ALU_ADD_K: 0 + 0x80008000 =
0xffffffff80008000 jited:1 92 PASS
[   54.345399] test_bpf: #100 ALU_SUB_X: 3 - 1 = 2 jited:1 77 PASS
[   54.346726] test_bpf: #101 ALU_SUB_X: 4294967295 - 4294967294 = 1
jited:1 72 PASS
[   54.347794] test_bpf: #102 ALU64_SUB_X: 3 - 1 = 2 jited:1 72 PASS
[   54.348826] test_bpf: #103 ALU64_SUB_X: 4294967295 - 4294967294 = 1
jited:1 71 PASS
[   54.349843] test_bpf: #104 ALU_SUB_K: 3 - 1 = 2 jited:1 120 PASS
[   54.351486] test_bpf: #105 ALU_SUB_K: 3 - 0 = 3 jited:1 82 PASS
[   54.352814] test_bpf: #106 ALU_SUB_K: 4294967295 - 4294967294 = 1
jited:1 103 PASS
[   54.354550] test_bpf: #107 ALU64_SUB_K: 3 - 1 = 2 jited:1 140 PASS
[   54.356822] test_bpf: #108 ALU64_SUB_K: 3 - 0 = 3 jited:1 117 PASS
[   54.359156] test_bpf: #109 ALU64_SUB_K: 4294967294 - 4294967295 =
-1 jited:1 83 PASS
[   54.360401] test_bpf: #110 ALU64_ADD_K: 2147483646 - 2147483647 =
-1 jited:1 77 PASS
[   54.361515] test_bpf: #111 ALU_MUL_X: 2 * 3 = 6 jited:1 68 PASS
[   54.362528] test_bpf: #112 ALU_MUL_X: 2 * 0x7FFFFFF8 = 0xFFFFFFF0
jited:1 70 PASS
[   54.363572] test_bpf: #113 ALU_MUL_X: -1 * -1 = 1 jited:1 73 PASS
[   54.364644] test_bpf: #114 ALU64_MUL_X: 2 * 3 = 6 jited:1 70 PASS
[   54.365655] test_bpf: #115 ALU64_MUL_X: 1 * 2147483647 = 2147483647
jited:1 75 PASS
[   54.366719] test_bpf: #116 ALU_MUL_K: 2 * 3 = 6 jited:1 67 PASS
[   54.367707] test_bpf: #117 ALU_MUL_K: 3 * 1 = 3 jited:1 71 PASS
[   54.368726] test_bpf: #118 ALU_MUL_K: 2 * 0x7FFFFFF8 = 0xFFFFFFF0
jited:1 70 PASS
[   54.369733] test_bpf: #119 ALU_MUL_K: 1 * (-1) = 0x00000000ffffffff
jited:1 153 PASS
[   54.371617] test_bpf: #120 ALU64_MUL_K: 2 * 3 = 6 jited:1 101 PASS
[   54.373505] test_bpf: #121 ALU64_MUL_K: 3 * 1 = 3 jited:1 108 PASS
[   54.375362] test_bpf: #122 ALU64_MUL_K: 1 * 2147483647 = 2147483647
jited:1 106 PASS
[   54.377242] test_bpf: #123 ALU64_MUL_K: 1 * -2147483647 =
-2147483647 jited:1 92 PASS
[   54.379044] test_bpf: #124 ALU64_MUL_K: 1 * (-1) =
0xffffffffffffffff jited:1 122 PASS
[   54.380863] test_bpf: #125 ALU_DIV_X: 6 / 2 = 3 jited:1 220 PASS
[   54.383591] test_bpf: #126 ALU_DIV_X: 4294967295 / 4294967295 = 1
jited:1 208 PASS
[   54.386292] test_bpf: #127 ALU64_DIV_X: 6 / 2 = 3 jited:0 736 PASS
[   54.394242] test_bpf: #128 ALU64_DIV_X: 2147483647 / 2147483647 = 1
jited:0 464 PASS
[   54.399433] test_bpf: #129 ALU64_DIV_X: 0xffffffffffffffff / (-1) =
0x0000000000000001 jited:0 743 PASS
[   54.407799] test_bpf: #130 ALU_DIV_K: 6 / 2 = 3 jited:1 246 PASS
[   54.410964] test_bpf: #131 ALU_DIV_K: 3 / 1 = 3 jited:1 199 PASS
[   54.413410] test_bpf: #132 ALU_DIV_K: 4294967295 / 4294967295 = 1
jited:1 192 PASS
[   54.415782] test_bpf: #133 ALU_DIV_K: 0xffffffffffffffff / (-1) =
0x1 jited:1 215 PASS
[   54.418414] test_bpf: #134 ALU64_DIV_K: 6 / 2 = 3 jited:0 364 PASS
[   54.422379] test_bpf: #135 ALU64_DIV_K: 3 / 1 = 3 jited:0 369 PASS
[   54.426692] test_bpf: #136 ALU64_DIV_K: 2147483647 / 2147483647 = 1
jited:0 380 PASS
[   54.430875] test_bpf: #137 ALU64_DIV_K: 0xffffffffffffffff / (-1) =
0x0000000000000001 jited:0 623 PASS
[   54.437429] test_bpf: #138 ALU_MOD_X: 3 % 2 = 1 jited:1 235 PASS
[   54.440177] test_bpf: #139 ALU_MOD_X: 4294967295 % 4294967293 = 2
jited:1 262 PASS
[   54.443183] test_bpf: #140 ALU64_MOD_X: 3 % 2 = 1 jited:0 1524 PASS
[   54.458988] test_bpf: #141 ALU64_MOD_X: 2147483647 % 2147483645 = 2
jited:0 720 PASS
[   54.466677] test_bpf: #142 ALU_MOD_K: 3 % 2 = 1 jited:1 231 PASS
[   54.469383] test_bpf: #143 ALU_MOD_K: 3 % 1 = 0 jited:1 PASS
[   54.469685] test_bpf: #144 ALU_MOD_K: 4294967295 % 4294967293 = 2
jited:1 257 PASS
[   54.472650] test_bpf: #145 ALU64_MOD_K: 3 % 2 = 1 jited:0 481 PASS
[   54.477765] test_bpf: #146 ALU64_MOD_K: 3 % 1 = 0 jited:0 PASS
[   54.478042] test_bpf: #147 ALU64_MOD_K: 2147483647 % 2147483645 = 2
jited:0 513 PASS
[   54.483455] test_bpf: #148 ALU_AND_X: 3 & 2 = 2 jited:1 100 PASS
[   54.484786] test_bpf: #149 ALU_AND_X: 0xffffffff & 0xffffffff =
0xffffffff jited:1 106 PASS
[   54.486335] test_bpf: #150 ALU64_AND_X: 3 & 2 = 2 jited:1 86 PASS
[   54.487738] test_bpf: #151 ALU64_AND_X: 0xffffffff & 0xffffffff =
0xffffffff jited:1 118 PASS
[   54.489623] test_bpf: #152 ALU_AND_K: 3 & 2 = 2 jited:1 117 PASS
[   54.491645] test_bpf: #153 ALU_AND_K: 0xffffffff & 0xffffffff =
0xffffffff jited:1 72 PASS
[   54.493119] test_bpf: #154 ALU64_AND_K: 3 & 2 = 2 jited:1 72 PASS
[   54.494195] test_bpf: #155 ALU64_AND_K: 0xffffffff & 0xffffffff =
0xffffffff jited:1 70 PASS
[   54.495330] test_bpf: #156 ALU64_AND_K: 0x0000ffffffff0000 & 0x0 =
0x0000ffff00000000 jited:1 99 PASS
[   54.496721] test_bpf: #157 ALU64_AND_K: 0x0000ffffffff0000 & -1 =
0x0000ffffffffffff jited:1 97 PASS
[   54.498106] test_bpf: #158 ALU64_AND_K: 0xffffffffffffffff & -1 =
0xffffffffffffffff jited:1 86 PASS
[   54.499343] test_bpf: #159 ALU_OR_X: 1 | 2 = 3 jited:1 73 PASS
[   54.500447] test_bpf: #160 ALU_OR_X: 0x0 | 0xffffffff = 0xffffffff
jited:1 72 PASS
[   54.501546] test_bpf: #161 ALU64_OR_X: 1 | 2 = 3 jited:1 89 PASS
[   54.502779] test_bpf: #162 ALU64_OR_X: 0 | 0xffffffff = 0xffffffff
jited:1 91 PASS
[   54.504154] test_bpf: #163 ALU_OR_K: 1 | 2 = 3 jited:1 71 PASS
[   54.505223] test_bpf: #164 ALU_OR_K: 0 & 0xffffffff = 0xffffffff
jited:1 116 PASS
[   54.506916] test_bpf: #165 ALU64_OR_K: 1 | 2 = 3 jited:1 77 PASS
[   54.508328] test_bpf: #166 ALU64_OR_K: 0 & 0xffffffff = 0xffffffff
jited:1 80 PASS
[   54.509666] test_bpf: #167 ALU64_OR_K: 0x0000ffffffff0000 | 0x0 =
0x0000ffff00000000 jited:1 86 PASS
[   54.511012] test_bpf: #168 ALU64_OR_K: 0x0000ffffffff0000 | -1 =
0xffffffffffffffff jited:1 99 PASS
[   54.512432] test_bpf: #169 ALU64_OR_K: 0x000000000000000 | -1 =
0xffffffffffffffff jited:1 147 PASS
[   54.514401] test_bpf: #170 ALU_XOR_X: 5 ^ 6 = 3 jited:1 80 PASS
[   54.515668] test_bpf: #171 ALU_XOR_X: 0x1 ^ 0xffffffff = 0xfffffffe
jited:1 73 PASS
[   54.516794] test_bpf: #172 ALU64_XOR_X: 5 ^ 6 = 3 jited:1 71 PASS
[   54.517879] test_bpf: #173 ALU64_XOR_X: 1 ^ 0xffffffff = 0xfffffffe
jited:1 72 PASS
[   54.518998] test_bpf: #174 ALU_XOR_K: 5 ^ 6 = 3 jited:1 71 PASS
[   54.520120] test_bpf: #175 ALU_XOR_K: 1 ^ 0xffffffff = 0xfffffffe
jited:1 67 PASS
[   54.521181] test_bpf: #176 ALU64_XOR_K: 5 ^ 6 = 3 jited:1 70 PASS
[   54.522292] test_bpf: #177 ALU64_XOR_K: 1 & 0xffffffff = 0xfffffffe
jited:1 104 PASS
[   54.523741] test_bpf: #178 ALU64_XOR_K: 0x0000ffffffff0000 ^ 0x0 =
0x0000ffffffff0000 jited:1 96 PASS
[   54.525269] test_bpf: #179 ALU64_XOR_K: 0x0000ffffffff0000 ^ -1 =
0xffff00000000ffff jited:1 119 PASS
[   54.526875] test_bpf: #180 ALU64_XOR_K: 0x000000000000000 ^ -1 =
0xffffffffffffffff jited:1 116 PASS
[   54.528421] test_bpf: #181 ALU_LSH_X: 1 << 1 = 2 jited:1 100 PASS
[   54.529848] test_bpf: #182 ALU_LSH_X: 1 << 31 = 0x80000000 jited:1 73 PASS
[   54.530965] test_bpf: #183 ALU64_LSH_X: 1 << 1 = 2 jited:1 119 PASS
[   54.532667] test_bpf: #184 ALU64_LSH_X: 1 << 31 = 0x80000000 jited:1 110 PASS
[   54.534257] test_bpf: #185 ALU_LSH_K: 1 << 1 = 2 jited:1 147 PASS
[   54.536290] test_bpf: #186 ALU_LSH_K: 1 << 31 = 0x80000000 jited:1 116 PASS
[   54.538165] test_bpf: #187 ALU64_LSH_K: 1 << 1 = 2 jited:1 154 PASS
[   54.540668] test_bpf: #188 ALU64_LSH_K: 1 << 31 = 0x80000000 jited:1 92 PASS
[   54.542464] test_bpf: #189 ALU_RSH_X: 2 >> 1 = 1 jited:1 86 PASS
[   54.543937] test_bpf: #190 ALU_RSH_X: 0x80000000 >> 31 = 1 jited:1 148 PASS
[   54.545995] test_bpf: #191 ALU64_RSH_X: 2 >> 1 = 1 jited:1 108 PASS
[   54.547759] test_bpf: #192 ALU64_RSH_X: 0x80000000 >> 31 = 1 jited:1 96 PASS
[   54.549178] test_bpf: #193 ALU_RSH_K: 2 >> 1 = 1 jited:1 68 PASS
[   54.550175] test_bpf: #194 ALU_RSH_K: 0x80000000 >> 31 = 1 jited:1 74 PASS
[   54.551208] test_bpf: #195 ALU64_RSH_K: 2 >> 1 = 1 jited:1 66 PASS
[   54.552193] test_bpf: #196 ALU64_RSH_K: 0x80000000 >> 31 = 1 jited:1 95 PASS
[   54.553449] test_bpf: #197 ALU_ARSH_X: 0xff00ff0000000000 >> 40 =
0xffffffffffff00ff jited:1 74 PASS
[   54.554566] test_bpf: #198 ALU_ARSH_K: 0xff00ff0000000000 >> 40 =
0xffffffffffff00ff jited:1 96 PASS
[   54.555984] test_bpf: #199 ALU_NEG: -(3) = -3 jited:1 84 PASS
[   54.557335] test_bpf: #200 ALU_NEG: -(-3) = 3 jited:1 72 PASS
[   54.558442] test_bpf: #201 ALU64_NEG: -(3) = -3 jited:1 74 PASS
[   54.559596] test_bpf: #202 ALU64_NEG: -(-3) = 3 jited:1 68 PASS
[   54.560664] test_bpf: #203 ALU_END_FROM_BE 16: 0x0123456789abcdef
-> 0xcdef jited:1 74 PASS
[   54.561814] test_bpf: #204 ALU_END_FROM_BE 32: 0x0123456789abcdef
-> 0x89abcdef jited:1 101 PASS
[   54.563242] test_bpf: #205 ALU_END_FROM_BE 64: 0x0123456789abcdef
-> 0x89abcdef jited:1 93 PASS
[   54.564578] test_bpf: #206 ALU_END_FROM_LE 16: 0x0123456789abcdef
-> 0xefcd jited:1 73 PASS
[   54.565750] test_bpf: #207 ALU_END_FROM_LE 32: 0x0123456789abcdef
-> 0xefcdab89 jited:1 76 PASS
[   54.566879] test_bpf: #208 ALU_END_FROM_LE 64: 0x0123456789abcdef
-> 0x67452301 jited:1 78 PASS
[   54.568009] test_bpf: #209 ST_MEM_B: Store/Load byte: max negative
jited:1 72 PASS
[   54.569258] test_bpf: #210 ST_MEM_B: Store/Load byte: max positive
jited:1 79 PASS
[   54.570402] test_bpf: #211 STX_MEM_B: Store/Load byte: max negative
jited:1 79 PASS
[   54.571541] test_bpf: #212 ST_MEM_H: Store/Load half word: max
negative jited:1 81 PASS
[   54.572896] test_bpf: #213 ST_MEM_H: Store/Load half word: max
positive jited:1 100 PASS
[   54.574521] test_bpf: #214 STX_MEM_H: Store/Load half word: max
negative jited:1 110 PASS
[   54.576159] test_bpf: #215 ST_MEM_W: Store/Load word: max negative
jited:1 75 PASS
[   54.577570] test_bpf: #216 ST_MEM_W: Store/Load word: max positive
jited:1 89 PASS
[   54.579195] test_bpf: #217 STX_MEM_W: Store/Load word: max negative
jited:1 122 PASS
[   54.581267] test_bpf: #218 ST_MEM_DW: Store/Load double word: max
negative jited:1 85 PASS
[   54.582954] test_bpf: #219 ST_MEM_DW: Store/Load double word: max
negative 2 jited:1 123 PASS
[   54.584677] test_bpf: #220 ST_MEM_DW: Store/Load double word: max
positive jited:1 78 PASS
[   54.585879] test_bpf: #221 STX_MEM_DW: Store/Load double word: max
negative jited:1 85 PASS
[   54.587106] test_bpf: #222 STX_XADD_W: Test: 0x12 + 0x10 = 0x22
jited:0 328 PASS
[   54.590869] test_bpf: #223 STX_XADD_W: Test side-effects, r10: 0x12
+ 0x10 = 0x22 jited:0 PASS
[   54.591178] test_bpf: #224 STX_XADD_W: Test side-effects, r0: 0x12
+ 0x10 = 0x22 jited:0 285 PASS
[   54.594489] test_bpf: #225 STX_XADD_W: X + 1 + 1 + 1 + ... jited:0
158746 PASS
[   56.182499] test_bpf: #226 STX_XADD_DW: Test: 0x12 + 0x10 = 0x22
jited:0 343 PASS
[   56.186642] test_bpf: #227 STX_XADD_DW: Test side-effects, r10:
0x12 + 0x10 = 0x22 jited:0 PASS
[   56.186926] test_bpf: #228 STX_XADD_DW: Test side-effects, r0: 0x12
+ 0x10 = 0x22 jited:0 272 PASS
[   56.190021] test_bpf: #229 STX_XADD_DW: X + 1 + 1 + 1 + ... jited:0
194997 PASS
[   58.140569] test_bpf: #230 JMP_EXIT jited:1 82 PASS
[   58.142427] test_bpf: #231 JMP_JA: Unconditional jump: if (true)
return 1 jited:1 86 PASS
[   58.155637] test_bpf: #232 JMP_JSGT_K: Signed jump: if (-1 > -2)
return 1 jited:1 86 PASS
[   58.157334] test_bpf: #233 JMP_JSGT_K: Signed jump: if (-1 > -1)
return 0 jited:1 82 PASS
[   58.158533] test_bpf: #234 JMP_JSGE_K: Signed jump: if (-1 >= -2)
return 1 jited:1 72 PASS
[   58.159560] test_bpf: #235 JMP_JSGE_K: Signed jump: if (-1 >= -1)
return 1 jited:1 73 PASS
[   58.160538] test_bpf: #236 JMP_JGT_K: if (3 > 2) return 1 jited:1 71 PASS
[   58.161457] test_bpf: #237 JMP_JGT_K: Unsigned jump: if (-1 > 1)
return 1 jited:1 72 PASS
[   58.162407] test_bpf: #238 JMP_JGE_K: if (3 >= 2) return 1 jited:1 77 PASS
[   58.163411] test_bpf: #239 JMP_JGT_K: if (3 > 2) return 1 (jump
backwards) jited:1 76 PASS
[   58.164416] test_bpf: #240 JMP_JGE_K: if (3 >= 3) return 1 jited:1 74 PASS
[   58.165391] test_bpf: #241 JMP_JNE_K: if (3 != 2) return 1 jited:1 74 PASS
[   58.166375] test_bpf: #242 JMP_JEQ_K: if (3 == 3) return 1 jited:1 78 PASS
[   58.167382] test_bpf: #243 JMP_JSET_K: if (0x3 & 0x2) return 1
jited:1 109 PASS
[   58.168822] test_bpf: #244 JMP_JSET_K: if (0x3 & 0xffffffff) return
1 jited:1 71 PASS
[   58.170396] test_bpf: #245 JMP_JSGT_X: Signed jump: if (-1 > -2)
return 1 jited:1 75 PASS
[   58.171568] test_bpf: #246 JMP_JSGT_X: Signed jump: if (-1 > -1)
return 0 jited:1 78 PASS
[   58.172804] test_bpf: #247 JMP_JSGE_X: Signed jump: if (-1 >= -2)
return 1 jited:1 134 PASS
[   58.175486] test_bpf: #248 JMP_JSGE_X: Signed jump: if (-1 >= -1)
return 1 jited:1 102 PASS
[   58.177403] test_bpf: #249 JMP_JGT_X: if (3 > 2) return 1 jited:1 83 PASS
[   58.178806] test_bpf: #250 JMP_JGT_X: Unsigned jump: if (-1 > 1)
return 1 jited:1 80 PASS
[   58.180104] test_bpf: #251 JMP_JGE_X: if (3 >= 2) return 1 jited:1 78 PASS
[   58.181230] test_bpf: #252 JMP_JGE_X: if (3 >= 3) return 1 jited:1 116 PASS
[   58.182751] test_bpf: #253 JMP_JGE_X: ldimm64 test 1 jited:1 81 PASS
[   58.183951] test_bpf: #254 JMP_JGE_X: ldimm64 test 2 jited:1 79 PASS
[   58.185334] test_bpf: #255 JMP_JGE_X: ldimm64 test 3 jited:1 78 PASS
[   58.186505] test_bpf: #256 JMP_JNE_X: if (3 != 2) return 1 jited:1 108 PASS
[   58.187991] test_bpf: #257 JMP_JEQ_X: if (3 == 3) return 1 jited:1 102 PASS
[   58.189496] test_bpf: #258 JMP_JSET_X: if (0x3 & 0x2) return 1
jited:1 133 PASS
[   58.191644] test_bpf: #259 JMP_JSET_X: if (0x3 & 0xffffffff) return
1 jited:1 128 PASS
[   58.193631] test_bpf: #260 JMP_JA: Jump, gap, jump, ... jited:1 108 PASS
[   58.195981] test_bpf: #261 BPF_MAXINSNS: Maximum possible literals
jited:1 111 PASS
[   58.211020] test_bpf: #262 BPF_MAXINSNS: Single literal jited:1 115 PASS
[   58.226185] test_bpf: #263 BPF_MAXINSNS: Run/add until end jited:1 8481 PASS
[   58.322910] test_bpf: #264 BPF_MAXINSNS: Too many instructions PASS
[   58.323076] test_bpf: #265 BPF_MAXINSNS: Very long jump jited:1 123 PASS
[   58.339381] test_bpf: #266 BPF_MAXINSNS: Ctx heavy transformations
jited:1 28166 29032 PASS
[   58.931050] test_bpf: #267 BPF_MAXINSNS: Call heavy transformations
jited:0 903498 894192 PASS
[   76.916296] test_bpf: #268 BPF_MAXINSNS: Jump heavy test jited:1 132663 PASS
[   78.260490] test_bpf: #269 BPF_MAXINSNS: Very long jump backwards
jited:1 148 PASS
[   78.269590] test_bpf: #270 BPF_MAXINSNS: Edge hopping nuthouse
jited:1 277097 PASS
[   81.046383] test_bpf: #271 BPF_MAXINSNS: Jump, gap, jump, ...
jited:1 1041 PASS
[   81.076916] test_bpf: #272 BPF_MAXINSNS: ld_abs+get_processor_id
jited:0 566894 PASS
[   86.754024] test_bpf: #273 BPF_MAXINSNS: ld_abs+vlan_push/pop
jited:0 602040 PASS
[   92.775504] test_bpf: #274 LD_IND byte frag jited:1 574 PASS
[   92.782876] test_bpf: #275 LD_IND halfword frag jited:1 641 PASS
[   92.790062] test_bpf: #276 LD_IND word frag jited:1 731 PASS
[   92.798321] test_bpf: #277 LD_IND halfword mixed head/frag jited:1 741 PASS
[   92.806601] test_bpf: #278 LD_IND word mixed head/frag jited:1 972 PASS
[   92.817542] test_bpf: #279 LD_ABS byte frag jited:1 601 PASS
[   92.824156] test_bpf: #280 LD_ABS halfword frag jited:1 603 PASS
[   92.830806] test_bpf: #281 LD_ABS word frag jited:1 688 PASS
[   92.838273] test_bpf: #282 LD_ABS halfword mixed head/frag jited:1 657 PASS
[   92.845562] test_bpf: #283 LD_ABS word mixed head/frag jited:1 748 PASS
[   92.853678] test_bpf: #284 LD_IND byte default X jited:1 178 PASS
[   92.856290] test_bpf: #285 LD_IND byte positive offset jited:1 187 PASS
[   92.858954] test_bpf: #286 LD_IND byte negative offset jited:1 178 PASS
[   92.861592] test_bpf: #287 LD_IND halfword positive offset jited:1 161 PASS
[   92.863726] test_bpf: #288 LD_IND halfword negative offset jited:1 195 PASS
[   92.866372] test_bpf: #289 LD_IND halfword unaligned jited:1 183 PASS
[   92.868821] test_bpf: #290 LD_IND word positive offset jited:1 170 PASS
[   92.871096] test_bpf: #291 LD_IND word negative offset jited:1 198 PASS
[   92.873832] test_bpf: #292 LD_IND word unaligned (addr & 3 == 2)
jited:1 281 PASS
[   92.877321] test_bpf: #293 LD_IND word unaligned (addr & 3 == 1)
jited:1 172 PASS
[   92.879493] test_bpf: #294 LD_IND word unaligned (addr & 3 == 3)
jited:1 171 PASS
[   92.881590] test_bpf: #295 LD_ABS byte jited:1 162 PASS
[   92.883535] test_bpf: #296 LD_ABS halfword jited:1 160 PASS
[   92.885486] test_bpf: #297 LD_ABS halfword unaligned jited:1 180 PASS
[   92.887650] test_bpf: #298 LD_ABS word jited:1 166 PASS
[   92.889661] test_bpf: #299 LD_ABS word unaligned (addr & 3 == 2)
jited:1 157 PASS
[   92.891595] test_bpf: #300 LD_ABS word unaligned (addr & 3 == 1)
jited:1 170 PASS
[   92.893662] test_bpf: #301 LD_ABS word unaligned (addr & 3 == 3)
jited:1 163 PASS
[   92.895660] test_bpf: #302 ADD default X jited:1 84 PASS
[   92.896895] test_bpf: #303 ADD default A jited:1 79 PASS
[   92.898143] test_bpf: #304 SUB default X jited:1 82 PASS
[   92.899284] test_bpf: #305 SUB default A jited:1 85 PASS
[   92.900529] test_bpf: #306 MUL default X jited:1 76 PASS
[   92.901642] test_bpf: #307 MUL default A jited:1 83 PASS
[   92.903045] test_bpf: #308 DIV default X jited:1 93 PASS
[   92.904524] test_bpf: #309 DIV default A jited:1 203 PASS
[   92.906955] test_bpf: #310 MOD default X jited:1 100 PASS
[   92.908398] test_bpf: #311 MOD default A jited:1 249 PASS
[   92.911232] test_bpf: #312 JMP EQ default A jited:1 83 PASS
[   92.912593] test_bpf: #313 JMP EQ default X jited:1 95 PASS
[   92.913931] test_bpf: Summary: 314 PASSED, 0 FAILED, [278/306 JIT'ed]

3) JIT + blinding enabled:

[root@vexpress modules]# insmod test_bpf.ko
[   56.044720] test_bpf: #0 TAX jited:1 239 218 229 PASS
[   56.054736] test_bpf: #1 TXA jited:1 89 119 85 PASS
[   56.064598] test_bpf: #2 ADD_SUB_MUL_K jited:1 213 PASS
[   56.067415] test_bpf: #3 DIV_MOD_KX jited:1 1190 PASS
[   56.080569] test_bpf: #4 AND_OR_LSH_K jited:1 200 149 PASS
[   56.084764] test_bpf: #5 LD_IMM_0 jited:1 101 PASS
[   56.086832] test_bpf: #6 LD_IND jited:1 314 310 283 PASS
[   56.096521] test_bpf: #7 LD_ABS jited:1 376 460 397 PASS
[   56.109604] test_bpf: #8 LD_ABS_LL jited:1 608 415 PASS
[   56.120753] test_bpf: #9 LD_IND_LL jited:1 248 256 268 PASS
[   56.129296] test_bpf: #10 LD_ABS_NET jited:1 435 420 PASS
[   56.138666] test_bpf: #11 LD_IND_NET jited:1 240 228 215 PASS
[   56.146039] test_bpf: #12 LD_PKTTYPE jited:1 211 274 PASS
[   56.151632] test_bpf: #13 LD_MARK jited:1 119 76 PASS
[   56.154522] test_bpf: #14 LD_RXHASH jited:1 78 70 PASS
[   56.156535] test_bpf: #15 LD_QUEUE jited:1 77 73 PASS
[   56.158482] test_bpf: #16 LD_PROTOCOL jited:1 326 320 PASS
[   56.165778] test_bpf: #17 LD_VLAN_TAG jited:1 129 86 PASS
[   56.168783] test_bpf: #18 LD_VLAN_TAG_PRESENT jited:1 87 88 PASS
[   56.170990] test_bpf: #19 LD_IFINDEX jited:1 97 95 PASS
[   56.173444] test_bpf: #20 LD_HATYPE jited:1 94 118 PASS
[   56.176033] test_bpf: #21 LD_CPU
[   56.176329] bpf_jit: *** NOT YET: opcode 85 ***
[   56.176565] jited:0 2639 702 PASS
[   56.210242] test_bpf: #22 LD_NLATTR jited:0 685 2101 PASS
[   56.238881] test_bpf: #23 LD_NLATTR_NEST jited:0 2323 3752 PASS
[   56.300600] test_bpf: #24 LD_PAYLOAD_OFF jited:0 4543 6842 PASS
[   56.415022] test_bpf: #25 LD_ANC_XOR jited:1 168 156 PASS
[   56.419429] test_bpf: #26 SPILL_FILL jited:1 232 212 219 PASS
[   56.427785] test_bpf: #27 JEQ jited:1 362 352 230 PASS
[   56.438180] test_bpf: #28 JGT jited:1 334 236 197 PASS
[   56.446672] test_bpf: #29 JGE jited:1 260 318 307 PASS
[   56.456301] test_bpf: #30 JSET jited:1 274 339 410 PASS
[   56.467681] test_bpf: #31 tcpdump port 22 jited:1 355 951 968 PASS
[   56.492091] test_bpf: #32 tcpdump complex jited:1 318 798 1308 PASS
[   56.517843] test_bpf: #33 RET_A jited:1 83 76 PASS
[   56.520000] test_bpf: #34 INT: ADD trivial jited:1 152 PASS
[   56.522183] test_bpf: #35 INT: MUL_X jited:1 192 PASS
[   56.524626] test_bpf: #36 INT: MUL_X2 jited:1 165 PASS
[   56.526762] test_bpf: #37 INT: MUL32_X jited:1 163 PASS
[   56.528828] test_bpf: #38 INT: ADD 64-bit jited:1 1507 PASS
[   56.544862] test_bpf: #39 INT: ADD 32-bit jited:1 954 PASS
[   56.555409] test_bpf: #40 INT: SUB jited:1 1159 PASS
[   56.567960] test_bpf: #41 INT: XOR jited:1 480 PASS
[   56.573431] test_bpf: #42 INT: MUL jited:1 486 PASS
[   56.579305] test_bpf: #43 MOV REG64 jited:1 274 PASS
[   56.583045] test_bpf: #44 MOV REG32 jited:1 253 PASS
[   56.586138] test_bpf: #45 LD IMM64 jited:1 578 PASS
[   56.592580] test_bpf: #46 INT: ALU MIX jited:0 1199 PASS
[   56.605346] test_bpf: #47 INT: shifts by register jited:1 381 PASS
[   56.610159] test_bpf: #48 INT: DIV + ABS jited:1 588 482 PASS
[   56.621545] test_bpf: #49 INT: DIV by zero jited:1 276 199 PASS
[   56.626894] test_bpf: #50 check: missing ret PASS
[   56.627249] test_bpf: #51 check: div_k_0 PASS
[   56.627403] test_bpf: #52 check: unknown insn PASS
[   56.627518] test_bpf: #53 check: out of range spill/fill PASS
[   56.627639] test_bpf: #54 JUMPS + HOLES jited:1 371 PASS
[   56.632295] test_bpf: #55 check: RET X PASS
[   56.632615] test_bpf: #56 check: LDX + RET X PASS
[   56.632748] test_bpf: #57 M[]: alt STX + LDX jited:1 621 PASS
[   56.639774] test_bpf: #58 M[]: full STX + full LDX jited:1 586 PASS
[   56.646535] test_bpf: #59 check: SKF_AD_MAX PASS
[   56.646837] test_bpf: #60 LD [SKF_AD_OFF-1] jited:1 195 PASS
[   56.649245] test_bpf: #61 load 64-bit immediate jited:1 220 PASS
[   56.652259] test_bpf: #62 nmap reduced jited:1 816 PASS
[   56.661508] test_bpf: #63 ALU_MOV_X: dst = 2 jited:1 76 PASS
[   56.662760] test_bpf: #64 ALU_MOV_X: dst = 4294967295 jited:1 79 PASS
[   56.663905] test_bpf: #65 ALU64_MOV_X: dst = 2 jited:1 80 PASS
[   56.665158] test_bpf: #66 ALU64_MOV_X: dst = 4294967295 jited:1 79 PASS
[   56.666297] test_bpf: #67 ALU_MOV_K: dst = 2 jited:1 75 PASS
[   56.667389] test_bpf: #68 ALU_MOV_K: dst = 4294967295 jited:1 73 PASS
[   56.668504] test_bpf: #69 ALU_MOV_K: 0x0000ffffffff0000 =
0x00000000ffffffff jited:1 195 PASS
[   56.670934] test_bpf: #70 ALU64_MOV_K: dst = 2 jited:1 77 PASS
[   56.672115] test_bpf: #71 ALU64_MOV_K: dst = 2147483647 jited:1 104 PASS
[   56.673550] test_bpf: #72 ALU64_OR_K: dst = 0x0 jited:1 215 PASS
[   56.676139] test_bpf: #73 ALU64_MOV_K: dst = -1 jited:1 173 PASS
[   56.687141] test_bpf: #74 ALU_ADD_X: 1 + 2 = 3 jited:1 114 PASS
[   56.688839] test_bpf: #75 ALU_ADD_X: 1 + 4294967294 = 4294967295
jited:1 112 PASS
[   56.690248] test_bpf: #76 ALU_ADD_X: 2 + 4294967294 = 0 jited:1 186 PASS
[   56.692428] test_bpf: #77 ALU64_ADD_X: 1 + 2 = 3 jited:1 159 PASS
[   56.694388] test_bpf: #78 ALU64_ADD_X: 1 + 4294967294 = 4294967295
jited:1 109 PASS
[   56.696115] test_bpf: #79 ALU64_ADD_X: 2 + 4294967294 = 4294967296
jited:1 218 PASS
[   56.698754] test_bpf: #80 ALU_ADD_K: 1 + 2 = 3 jited:1 120 PASS
[   56.700479] test_bpf: #81 ALU_ADD_K: 3 + 0 = 3 jited:1 118 PASS
[   56.702378] test_bpf: #82 ALU_ADD_K: 1 + 4294967294 = 4294967295
jited:1 121 PASS
[   56.704284] test_bpf: #83 ALU_ADD_K: 4294967294 + 2 = 0 jited:1 139 PASS
[   56.706363] test_bpf: #84 ALU_ADD_K: 0 + (-1) = 0x00000000ffffffff
jited:1 176 PASS
[   56.708715] test_bpf: #85 ALU_ADD_K: 0 + 0xffff = 0xffff jited:1 190 PASS
[   56.711155] test_bpf: #86 ALU_ADD_K: 0 + 0x7fffffff = 0x7fffffff
jited:1 228 PASS
[   56.713878] test_bpf: #87 ALU_ADD_K: 0 + 0x80000000 = 0x80000000
jited:1 198 PASS
[   56.716318] test_bpf: #88 ALU_ADD_K: 0 + 0x80008000 = 0x80008000
jited:1 189 PASS
[   56.718657] test_bpf: #89 ALU64_ADD_K: 1 + 2 = 3 jited:1 112 PASS
[   56.720152] test_bpf: #90 ALU64_ADD_K: 3 + 0 = 3 jited:1 111 PASS
[   56.721639] test_bpf: #91 ALU64_ADD_K: 1 + 2147483646 = 2147483647
jited:1 138 PASS
[   56.723403] test_bpf: #92 ALU64_ADD_K: 4294967294 + 2 = 4294967296
jited:1 151 PASS
[   56.725349] test_bpf: #93 ALU64_ADD_K: 2147483646 + -2147483647 =
-1 jited:1 115 PASS
[   56.726923] test_bpf: #94 ALU64_ADD_K: 1 + 0 = 1 jited:1 206 PASS
[   56.729436] test_bpf: #95 ALU64_ADD_K: 0 + (-1) =
0xffffffffffffffff jited:1 211 PASS
[   56.731988] test_bpf: #96 ALU64_ADD_K: 0 + 0xffff = 0xffff jited:1 250 PASS
[   56.735291] test_bpf: #97 ALU64_ADD_K: 0 + 0x7fffffff = 0x7fffffff
jited:1 199 PASS
[   56.737871] test_bpf: #98 ALU64_ADD_K: 0 + 0x80000000 =
0xffffffff80000000 jited:1 177 PASS
[   56.740193] test_bpf: #99 ALU_ADD_K: 0 + 0x80008000 =
0xffffffff80008000 jited:1 243 PASS
[   56.743126] test_bpf: #100 ALU_SUB_X: 3 - 1 = 2 jited:1 108 PASS
[   56.744676] test_bpf: #101 ALU_SUB_X: 4294967295 - 4294967294 = 1
jited:1 133 PASS
[   56.746386] test_bpf: #102 ALU64_SUB_X: 3 - 1 = 2 jited:1 110 PASS
[   56.747835] test_bpf: #103 ALU64_SUB_X: 4294967295 - 4294967294 = 1
jited:1 111 PASS
[   56.749292] test_bpf: #104 ALU_SUB_K: 3 - 1 = 2 jited:1 110 PASS
[   56.750766] test_bpf: #105 ALU_SUB_K: 3 - 0 = 3 jited:1 123 PASS
[   56.752371] test_bpf: #106 ALU_SUB_K: 4294967295 - 4294967294 = 1
jited:1 124 PASS
[   56.754095] test_bpf: #107 ALU64_SUB_K: 3 - 1 = 2 jited:1 116 PASS
[   56.755687] test_bpf: #108 ALU64_SUB_K: 3 - 0 = 3 jited:1 133 PASS
[   56.757418] test_bpf: #109 ALU64_SUB_K: 4294967294 - 4294967295 =
-1 jited:1 148 PASS
[   56.759295] test_bpf: #110 ALU64_ADD_K: 2147483646 - 2147483647 =
-1 jited:1 145 PASS
[   56.761137] test_bpf: #111 ALU_MUL_X: 2 * 3 = 6 jited:1 172 PASS
[   56.763380] test_bpf: #112 ALU_MUL_X: 2 * 0x7FFFFFF8 = 0xFFFFFFF0
jited:1 117 PASS
[   56.764943] test_bpf: #113 ALU_MUL_X: -1 * -1 = 1 jited:1 109 PASS
[   56.766424] test_bpf: #114 ALU64_MUL_X: 2 * 3 = 6 jited:1 115 PASS
[   56.767999] test_bpf: #115 ALU64_MUL_X: 1 * 2147483647 = 2147483647
jited:1 119 PASS
[   56.769584] test_bpf: #116 ALU_MUL_K: 2 * 3 = 6 jited:1 111 PASS
[   56.771124] test_bpf: #117 ALU_MUL_K: 3 * 1 = 3 jited:1 118 PASS
[   56.772961] test_bpf: #118 ALU_MUL_K: 2 * 0x7FFFFFF8 = 0xFFFFFFF0
jited:1 109 PASS
[   56.774431] test_bpf: #119 ALU_MUL_K: 1 * (-1) = 0x00000000ffffffff
jited:1 201 PASS
[   56.776888] test_bpf: #120 ALU64_MUL_K: 2 * 3 = 6 jited:1 116 PASS
[   56.778460] test_bpf: #121 ALU64_MUL_K: 3 * 1 = 3 jited:1 115 PASS
[   56.779993] test_bpf: #122 ALU64_MUL_K: 1 * 2147483647 = 2147483647
jited:1 278 PASS
[   56.783229] test_bpf: #123 ALU64_MUL_K: 1 * -2147483647 =
-2147483647 jited:1 125 PASS
[   56.785228] test_bpf: #124 ALU64_MUL_K: 1 * (-1) =
0xffffffffffffffff jited:1 208 PASS
[   56.787912] test_bpf: #125 ALU_DIV_X: 6 / 2 = 3 jited:1 246 PASS
[   56.790983] test_bpf: #126 ALU_DIV_X: 4294967295 / 4294967295 = 1
jited:1 291 PASS
[   56.794583] test_bpf: #127 ALU64_DIV_X: 6 / 2 = 3 jited:0 449 PASS
[   56.799521] test_bpf: #128 ALU64_DIV_X: 2147483647 / 2147483647 = 1
jited:0 462 PASS
[   56.804433] test_bpf: #129 ALU64_DIV_X: 0xffffffffffffffff / (-1) =
0x0000000000000001 jited:0 602 PASS
[   56.810815] test_bpf: #130 ALU_DIV_K: 6 / 2 = 3 jited:1 234 PASS
[   56.813585] test_bpf: #131 ALU_DIV_K: 3 / 1 = 3 jited:1 240 PASS
[   56.816466] test_bpf: #132 ALU_DIV_K: 4294967295 / 4294967295 = 1
jited:1 276 PASS
[   56.819790] test_bpf: #133 ALU_DIV_K: 0xffffffffffffffff / (-1) =
0x1 jited:1 373 PASS
[   56.824311] test_bpf: #134 ALU64_DIV_K: 6 / 2 = 3 jited:0 367 PASS
[   56.828509] test_bpf: #135 ALU64_DIV_K: 3 / 1 = 3 jited:0 354 PASS
[   56.832439] test_bpf: #136 ALU64_DIV_K: 2147483647 / 2147483647 = 1
jited:0 358 PASS
[   56.836360] test_bpf: #137 ALU64_DIV_K: 0xffffffffffffffff / (-1) =
0x0000000000000001 jited:0 563 PASS
[   56.842408] test_bpf: #138 ALU_MOD_X: 3 % 2 = 1 jited:1 293 PASS
[   56.845744] test_bpf: #139 ALU_MOD_X: 4294967295 % 4294967293 = 2
jited:1 289 PASS
[   56.849070] test_bpf: #140 ALU64_MOD_X: 3 % 2 = 1 jited:0 660 PASS
[   56.856100] test_bpf: #141 ALU64_MOD_X: 2147483647 % 2147483645 = 2
jited:0 692 PASS
[   56.863515] test_bpf: #142 ALU_MOD_K: 3 % 2 = 1 jited:1 311 PASS
[   56.867145] test_bpf: #143 ALU_MOD_K: 3 % 1 = 0 jited:1 PASS
[   56.867640] test_bpf: #144 ALU_MOD_K: 4294967295 % 4294967293 = 2
jited:1 319 PASS
[   56.871208] test_bpf: #145 ALU64_MOD_K: 3 % 2 = 1 jited:0 539 PASS
[   56.876982] test_bpf: #146 ALU64_MOD_K: 3 % 1 = 0 jited:0 PASS
[   56.877292] test_bpf: #147 ALU64_MOD_K: 2147483647 % 2147483645 = 2
jited:0 499 PASS
[   56.882591] test_bpf: #148 ALU_AND_X: 3 & 2 = 2 jited:1 109 PASS
[   56.884070] test_bpf: #149 ALU_AND_X: 0xffffffff & 0xffffffff =
0xffffffff jited:1 130 PASS
[   56.885807] test_bpf: #150 ALU64_AND_X: 3 & 2 = 2 jited:1 106 PASS
[   56.887288] test_bpf: #151 ALU64_AND_X: 0xffffffff & 0xffffffff =
0xffffffff jited:1 102 PASS
[   56.888746] test_bpf: #152 ALU_AND_K: 3 & 2 = 2 jited:1 114 PASS
[   56.890232] test_bpf: #153 ALU_AND_K: 0xffffffff & 0xffffffff =
0xffffffff jited:1 138 PASS
[   56.891967] test_bpf: #154 ALU64_AND_K: 3 & 2 = 2 jited:1 110 PASS
[   56.893502] test_bpf: #155 ALU64_AND_K: 0xffffffff & 0xffffffff =
0xffffffff jited:1 148 PASS
[   56.895413] test_bpf: #156 ALU64_AND_K: 0x0000ffffffff0000 & 0x0 =
0x0000ffff00000000 jited:1 206 PASS
[   56.897993] test_bpf: #157 ALU64_AND_K: 0x0000ffffffff0000 & -1 =
0x0000ffffffffffff jited:1 176 PASS
[   56.900294] test_bpf: #158 ALU64_AND_K: 0xffffffffffffffff & -1 =
0xffffffffffffffff jited:1 271 PASS
[   56.903712] test_bpf: #159 ALU_OR_X: 1 | 2 = 3 jited:1 108 PASS
[   56.905547] test_bpf: #160 ALU_OR_X: 0x0 | 0xffffffff = 0xffffffff
jited:1 118 PASS
[   56.907467] test_bpf: #161 ALU64_OR_X: 1 | 2 = 3 jited:1 103 PASS
[   56.909247] test_bpf: #162 ALU64_OR_X: 0 | 0xffffffff = 0xffffffff
jited:1 143 PASS
[   56.911219] test_bpf: #163 ALU_OR_K: 1 | 2 = 3 jited:1 123 PASS
[   56.913042] test_bpf: #164 ALU_OR_K: 0 & 0xffffffff = 0xffffffff
jited:1 110 PASS
[   56.914579] test_bpf: #165 ALU64_OR_K: 1 | 2 = 3 jited:1 120 PASS
[   56.916390] test_bpf: #166 ALU64_OR_K: 0 & 0xffffffff = 0xffffffff
jited:1 119 PASS
[   56.918118] test_bpf: #167 ALU64_OR_K: 0x0000ffffffff0000 | 0x0 =
0x0000ffff00000000 jited:1 212 PASS
[   56.920808] test_bpf: #168 ALU64_OR_K: 0x0000ffffffff0000 | -1 =
0xffffffffffffffff jited:1 221 PASS
[   56.923458] test_bpf: #169 ALU64_OR_K: 0x000000000000000 | -1 =
0xffffffffffffffff jited:1 198 PASS
[   56.925881] test_bpf: #170 ALU_XOR_X: 5 ^ 6 = 3 jited:1 138 PASS
[   56.927678] test_bpf: #171 ALU_XOR_X: 0x1 ^ 0xffffffff = 0xfffffffe
jited:1 130 PASS
[   56.929353] test_bpf: #172 ALU64_XOR_X: 5 ^ 6 = 3 jited:1 114 PASS
[   56.930850] test_bpf: #173 ALU64_XOR_X: 1 ^ 0xffffffff = 0xfffffffe
jited:1 106 PASS
[   56.932277] test_bpf: #174 ALU_XOR_K: 5 ^ 6 = 3 jited:1 112 PASS
[   56.933790] test_bpf: #175 ALU_XOR_K: 1 ^ 0xffffffff = 0xfffffffe
jited:1 116 PASS
[   56.935371] test_bpf: #176 ALU64_XOR_K: 5 ^ 6 = 3 jited:1 114 PASS
[   56.936942] test_bpf: #177 ALU64_XOR_K: 1 & 0xffffffff = 0xfffffffe
jited:1 112 PASS
[   56.938503] test_bpf: #178 ALU64_XOR_K: 0x0000ffffffff0000 ^ 0x0 =
0x0000ffffffff0000 jited:1 201 PASS
[   56.940978] test_bpf: #179 ALU64_XOR_K: 0x0000ffffffff0000 ^ -1 =
0xffff00000000ffff jited:1 242 PASS
[   56.943908] test_bpf: #180 ALU64_XOR_K: 0x000000000000000 ^ -1 =
0xffffffffffffffff jited:1 208 PASS
[   56.946575] test_bpf: #181 ALU_LSH_X: 1 << 1 = 2 jited:1 112 PASS
[   56.948252] test_bpf: #182 ALU_LSH_X: 1 << 31 = 0x80000000 jited:1 137 PASS
[   56.950466] test_bpf: #183 ALU64_LSH_X: 1 << 1 = 2 jited:1 163 PASS
[   56.953176] test_bpf: #184 ALU64_LSH_X: 1 << 31 = 0x80000000 jited:1 145 PASS
[   56.955105] test_bpf: #185 ALU_LSH_K: 1 << 1 = 2 jited:1 92 PASS
[   56.956400] test_bpf: #186 ALU_LSH_K: 1 << 31 = 0x80000000 jited:1 94 PASS
[   56.957700] test_bpf: #187 ALU64_LSH_K: 1 << 1 = 2 jited:1 94 PASS
[   56.959086] test_bpf: #188 ALU64_LSH_K: 1 << 31 = 0x80000000 jited:1 127 PASS
[   56.960779] test_bpf: #189 ALU_RSH_X: 2 >> 1 = 1 jited:1 135 PASS
[   56.962532] test_bpf: #190 ALU_RSH_X: 0x80000000 >> 31 = 1 jited:1 109 PASS
[   56.964027] test_bpf: #191 ALU64_RSH_X: 2 >> 1 = 1 jited:1 123 PASS
[   56.965961] test_bpf: #192 ALU64_RSH_X: 0x80000000 >> 31 = 1 jited:1 117 PASS
[   56.967517] test_bpf: #193 ALU_RSH_K: 2 >> 1 = 1 jited:1 95 PASS
[   56.968874] test_bpf: #194 ALU_RSH_K: 0x80000000 >> 31 = 1 jited:1 103 PASS
[   56.970261] test_bpf: #195 ALU64_RSH_K: 2 >> 1 = 1 jited:1 124 PASS
[   56.971879] test_bpf: #196 ALU64_RSH_K: 0x80000000 >> 31 = 1 jited:1 107 PASS
[   56.973346] test_bpf: #197 ALU_ARSH_X: 0xff00ff0000000000 >> 40 =
0xffffffffffff00ff jited:1 125 PASS
[   56.975022] test_bpf: #198 ALU_ARSH_K: 0xff00ff0000000000 >> 40 =
0xffffffffffff00ff jited:1 105 PASS
[   56.976479] test_bpf: #199 ALU_NEG: -(3) = -3 jited:1 76 PASS
[   56.977591] test_bpf: #200 ALU_NEG: -(-3) = 3 jited:1 106 PASS
[   56.979068] test_bpf: #201 ALU64_NEG: -(3) = -3 jited:1 104 PASS
[   56.980508] test_bpf: #202 ALU64_NEG: -(-3) = 3 jited:1 135 PASS
[   56.982223] test_bpf: #203 ALU_END_FROM_BE 16: 0x0123456789abcdef
-> 0xcdef jited:1 115 PASS
[   56.984458] test_bpf: #204 ALU_END_FROM_BE 32: 0x0123456789abcdef
-> 0x89abcdef jited:1 101 PASS
[   56.985991] test_bpf: #205 ALU_END_FROM_BE 64: 0x0123456789abcdef
-> 0x89abcdef jited:1 103 PASS
[   56.987477] test_bpf: #206 ALU_END_FROM_LE 16: 0x0123456789abcdef
-> 0xefcd jited:1 107 PASS
[   56.988937] test_bpf: #207 ALU_END_FROM_LE 32: 0x0123456789abcdef
-> 0xefcdab89 jited:1 93 PASS
[   56.990256] test_bpf: #208 ALU_END_FROM_LE 64: 0x0123456789abcdef
-> 0x67452301 jited:1 108 PASS
[   56.991728] test_bpf: #209 ST_MEM_B: Store/Load byte: max negative
jited:1 168 PASS
[   56.993878] test_bpf: #210 ST_MEM_B: Store/Load byte: max positive
jited:1 105 PASS
[   56.995386] test_bpf: #211 STX_MEM_B: Store/Load byte: max negative
jited:1 140 PASS
[   56.997188] test_bpf: #212 ST_MEM_H: Store/Load half word: max
negative jited:1 98 PASS
[   56.998563] test_bpf: #213 ST_MEM_H: Store/Load half word: max
positive jited:1 109 PASS
[   57.000045] test_bpf: #214 STX_MEM_H: Store/Load half word: max
negative jited:1 134 PASS
[   57.001803] test_bpf: #215 ST_MEM_W: Store/Load word: max negative
jited:1 148 PASS
[   57.003666] test_bpf: #216 ST_MEM_W: Store/Load word: max positive
jited:1 136 PASS
[   57.006376] test_bpf: #217 STX_MEM_W: Store/Load word: max negative
jited:1 205 PASS
[   57.009004] test_bpf: #218 ST_MEM_DW: Store/Load double word: max
negative jited:1 124 PASS
[   57.011164] test_bpf: #219 ST_MEM_DW: Store/Load double word: max
negative 2 jited:1 222 PASS
[   57.014281] test_bpf: #220 ST_MEM_DW: Store/Load double word: max
positive jited:1 110 PASS
[   57.016138] test_bpf: #221 STX_MEM_DW: Store/Load double word: max
negative jited:1 194 PASS
[   57.018614] test_bpf: #222 STX_XADD_W: Test: 0x12 + 0x10 = 0x22
jited:0 292 PASS
[   57.022064] test_bpf: #223 STX_XADD_W: Test side-effects, r10: 0x12
+ 0x10 = 0x22 jited:0 PASS
[   57.022356] test_bpf: #224 STX_XADD_W: Test side-effects, r0: 0x12
+ 0x10 = 0x22 jited:0 241 PASS
[   57.025099] test_bpf: #225 STX_XADD_W: X + 1 + 1 + 1 + ... jited:0
142752 PASS
[   58.454867] test_bpf: #226 STX_XADD_DW: Test: 0x12 + 0x10 = 0x22
jited:0 370 PASS
[   58.459675] test_bpf: #227 STX_XADD_DW: Test side-effects, r10:
0x12 + 0x10 = 0x22 jited:0 PASS
[   58.460082] test_bpf: #228 STX_XADD_DW: Test side-effects, r0: 0x12
+ 0x10 = 0x22 jited:0 268 PASS
[   58.463093] test_bpf: #229 STX_XADD_DW: X + 1 + 1 + 1 + ... jited:0
224885 PASS
[   60.713635] test_bpf: #230 JMP_EXIT jited:1 77 PASS
[   60.715476] test_bpf: #231 JMP_JA: Unconditional jump: if (true)
return 1 jited:1 84 PASS
[   60.716748] test_bpf: #232 JMP_JSGT_K: Signed jump: if (-1 > -2)
return 1 jited:1 128 PASS
[   60.718617] test_bpf: #233 JMP_JSGT_K: Signed jump: if (-1 > -1)
return 0 jited:1 126 PASS
[   60.720303] test_bpf: #234 JMP_JSGE_K: Signed jump: if (-1 >= -2)
return 1 jited:1 179 PASS
[   60.722889] test_bpf: #235 JMP_JSGE_K: Signed jump: if (-1 >= -1)
return 1 jited:1 125 PASS
[   60.724674] test_bpf: #236 JMP_JGT_K: if (3 > 2) return 1 jited:1 142 PASS
[   60.726577] test_bpf: #237 JMP_JGT_K: Unsigned jump: if (-1 > 1)
return 1 jited:1 161 PASS
[   60.728695] test_bpf: #238 JMP_JGE_K: if (3 >= 2) return 1 jited:1 163 PASS
[   60.730807] test_bpf: #239 JMP_JGT_K: if (3 > 2) return 1 (jump
backwards) jited:1 143 PASS
[   60.733042] test_bpf: #240 JMP_JGE_K: if (3 >= 3) return 1 jited:1 179 PASS
[   60.735513] test_bpf: #241 JMP_JNE_K: if (3 != 2) return 1 jited:1 144 PASS
[   60.737586] test_bpf: #242 JMP_JEQ_K: if (3 == 3) return 1 jited:1 144 PASS
[   60.739896] test_bpf: #243 JMP_JSET_K: if (0x3 & 0x2) return 1
jited:1 149 PASS
[   60.741813] test_bpf: #244 JMP_JSET_K: if (0x3 & 0xffffffff) return
1 jited:1 153 PASS
[   60.743773] test_bpf: #245 JMP_JSGT_X: Signed jump: if (-1 > -2)
return 1 jited:1 162 PASS
[   60.745798] test_bpf: #246 JMP_JSGT_X: Signed jump: if (-1 > -1)
return 0 jited:1 162 PASS
[   60.747921] test_bpf: #247 JMP_JSGE_X: Signed jump: if (-1 >= -2)
return 1 jited:1 178 PASS
[   60.750577] test_bpf: #248 JMP_JSGE_X: Signed jump: if (-1 >= -1)
return 1 jited:1 192 PASS
[   60.753315] test_bpf: #249 JMP_JGT_X: if (3 > 2) return 1 jited:1 205 PASS
[   60.756115] test_bpf: #250 JMP_JGT_X: Unsigned jump: if (-1 > 1)
return 1 jited:1 154 PASS
[   60.758287] test_bpf: #251 JMP_JGE_X: if (3 >= 2) return 1 jited:1 177 PASS
[   60.760611] test_bpf: #252 JMP_JGE_X: if (3 >= 3) return 1 jited:1 160 PASS
[   60.762901] test_bpf: #253 JMP_JGE_X: ldimm64 test 1 jited:1 204 PASS
[   60.765394] test_bpf: #254 JMP_JGE_X: ldimm64 test 2 jited:1 201 PASS
[   60.767884] test_bpf: #255 JMP_JGE_X: ldimm64 test 3 jited:1 184 PASS
[   60.770228] test_bpf: #256 JMP_JNE_X: if (3 != 2) return 1 jited:1 168 PASS
[   60.772331] test_bpf: #257 JMP_JEQ_X: if (3 == 3) return 1 jited:1 197 PASS
[   60.774754] test_bpf: #258 JMP_JSET_X: if (0x3 & 0x2) return 1
jited:1 192 PASS
[   60.777384] test_bpf: #259 JMP_JSET_X: if (0x3 & 0xffffffff) return
1 jited:1 181 PASS
[   60.779641] test_bpf: #260 JMP_JA: Jump, gap, jump, ... jited:1 97 PASS
[   60.781022] test_bpf: #261 BPF_MAXINSNS: Maximum possible literals
jited:1 125 PASS
[   61.242879] test_bpf: #262 BPF_MAXINSNS: Single literal jited:1 105 PASS
[   61.835125] test_bpf: #263 BPF_MAXINSNS: Run/add until end jited:1
121315 PASS
[   63.362129] test_bpf: #264 BPF_MAXINSNS: Too many instructions PASS
[   63.362231] test_bpf: #265 BPF_MAXINSNS: Very long jump jited:1 131 PASS
[   63.879679] test_bpf: #266 BPF_MAXINSNS: Ctx heavy transformations
jited:1 217030 181848 PASS
[   68.492725] test_bpf: #267 BPF_MAXINSNS: Call heavy transformations
jited:0 1018683 930359 PASS
[   88.007480] test_bpf: #268 BPF_MAXINSNS: Jump heavy test jited:1 440621 PASS
[   93.074379] test_bpf: #269 BPF_MAXINSNS: Very long jump backwards
jited:1 154 PASS
[   93.358458] test_bpf: #270 BPF_MAXINSNS: Edge hopping nuthouse
jited:1 302835 PASS
[   96.392483] test_bpf: #271 BPF_MAXINSNS: Jump, gap, jump, ...
jited:1 1008 PASS
[   96.501153] test_bpf: #272 BPF_MAXINSNS: ld_abs+get_processor_id
jited:0 597855 PASS
[  102.759854] test_bpf: #273 BPF_MAXINSNS: ld_abs+vlan_push/pop
jited:0 626616 PASS
[  109.247312] test_bpf: #274 LD_IND byte frag jited:1 1453 PASS
[  109.263829] test_bpf: #275 LD_IND halfword frag jited:1 600 PASS
[  109.270433] test_bpf: #276 LD_IND word frag jited:1 719 PASS
[  109.278159] test_bpf: #277 LD_IND halfword mixed head/frag jited:1 705 PASS
[  109.285898] test_bpf: #278 LD_IND word mixed head/frag jited:1 732 PASS
[  109.293879] test_bpf: #279 LD_ABS byte frag jited:1 683 PASS
[  109.301360] test_bpf: #280 LD_ABS halfword frag jited:1 595 PASS
[  109.307841] test_bpf: #281 LD_ABS word frag jited:1 672 PASS
[  109.315579] test_bpf: #282 LD_ABS halfword mixed head/frag jited:1 775 PASS
[  109.323890] test_bpf: #283 LD_ABS word mixed head/frag jited:1 725 PASS
[  109.331927] test_bpf: #284 LD_IND byte default X jited:1 274 PASS
[  109.335451] test_bpf: #285 LD_IND byte positive offset jited:1 302 PASS
[  109.339511] test_bpf: #286 LD_IND byte negative offset jited:1 311 PASS
[  109.343448] test_bpf: #287 LD_IND halfword positive offset jited:1 218 PASS
[  109.346282] test_bpf: #288 LD_IND halfword negative offset jited:1 193 PASS
[  109.348832] test_bpf: #289 LD_IND halfword unaligned jited:1 190 PASS
[  109.351330] test_bpf: #290 LD_IND word positive offset jited:1 200 PASS
[  109.353993] test_bpf: #291 LD_IND word negative offset jited:1 216 PASS
[  109.356739] test_bpf: #292 LD_IND word unaligned (addr & 3 == 2)
jited:1 195 PASS
[  109.359225] test_bpf: #293 LD_IND word unaligned (addr & 3 == 1)
jited:1 196 PASS
[  109.361713] test_bpf: #294 LD_IND word unaligned (addr & 3 == 3)
jited:1 221 PASS
[  109.364417] test_bpf: #295 LD_ABS byte jited:1 195 PASS
[  109.366896] test_bpf: #296 LD_ABS halfword jited:1 170 PASS
[  109.369093] test_bpf: #297 LD_ABS halfword unaligned jited:1 167 PASS
[  109.371399] test_bpf: #298 LD_ABS word jited:1 182 PASS
[  109.373724] test_bpf: #299 LD_ABS word unaligned (addr & 3 == 2)
jited:1 185 PASS
[  109.376064] test_bpf: #300 LD_ABS word unaligned (addr & 3 == 1)
jited:1 162 PASS
[  109.381701] test_bpf: #301 LD_ABS word unaligned (addr & 3 == 3)
jited:1 231 PASS
[  109.384839] test_bpf: #302 ADD default X jited:1 105 PASS
[  109.386839] test_bpf: #303 ADD default A jited:1 101 PASS
[  109.388677] test_bpf: #304 SUB default X jited:1 106 PASS
[  109.390267] test_bpf: #305 SUB default A jited:1 119 PASS
[  109.391992] test_bpf: #306 MUL default X jited:1 131 PASS
[  109.394020] test_bpf: #307 MUL default A jited:1 116 PASS
[  109.395766] test_bpf: #308 DIV default X jited:1 116 PASS
[  109.397706] test_bpf: #309 DIV default A jited:1 227 PASS
[  109.406156] test_bpf: #310 MOD default X jited:1 98 PASS
[  109.407645] test_bpf: #311 MOD default A jited:1 265 PASS
[  109.410774] test_bpf: #312 JMP EQ default A jited:1 134 PASS
[  109.412679] test_bpf: #313 JMP EQ default X jited:1 108 PASS
[  109.414506] test_bpf: Summary: 314 PASSED, 0 FAILED, [278/306 JIT'ed]


These all benchmarks are for ARMv7.
Best,
Shubham Bansal


On Mon, May 22, 2017 at 6:31 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 05/20/2017 10:01 PM, Shubham Bansal wrote:
> [...]
>>
>> Before I send the patch, I have tested the JIT compiler on ARMv7 but
>> not on ARMv5 or ARMv6. So can you tell me which arch versions I should
>> test it for?
>> Also for my testing, CONFIG_FRAME_POINTER and CONFIG_CPU_BIG_ENDIAN
>> are both disabled. But I need to test JIT with these flags as well.
>> Whenever I put these flags in .config file, the arm kernel is not
>> getting compiler with these flags. Can you tell me why? If you need
>> more information regarding this, please let me know.
>
>
> Maybe Mircea, Kees or someone from linux-arm-kernel can help you out
> on that.
>
> With regards to the below benchmark, I was mentioning how it compares
> to the interpreter. With only the numbers for jit it's hard to compare.
> So would be great to see the output for the following three cases:
>
> 1) Interpreter:
>
> echo 0 > /proc/sys/net/core/bpf_jit_enable
>
> 2) JIT enabled:
>
> echo 1 > /proc/sys/net/core/bpf_jit_enable
>
> 3) JIT + blinding enabled:
>
> echo 1 > /proc/sys/net/core/bpf_jit_enable
> echo 2 > /proc/sys/net/core/bpf_jit_harden
>
>> With current config for ARMv7, benchmarks are :
>>
>> [root@vexpress modules]# insmod test_bpf.ko
>> [   25.797766] test_bpf: #0 TAX jited:1 180 170 169 PASS
>> [   25.811395] test_bpf: #1 TXA jited:1 93 89 111 PASS
>> [   25.815073] test_bpf: #2 ADD_SUB_MUL_K jited:1 94 PASS
>> [   25.816779] test_bpf: #3 DIV_MOD_KX jited:1 983 PASS
>> [   25.827310] test_bpf: #4 AND_OR_LSH_K jited:1 94 93 PASS
>> [   25.829843] test_bpf: #5 LD_IMM_0 jited:1 83 PASS
>> [   25.831260] test_bpf: #6 LD_IND jited:1 338 266 305 PASS
>
> [...]
>
> Thanks,
> Daniel
