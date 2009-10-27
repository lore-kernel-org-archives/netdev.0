From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Mon, 26 Oct 2009 22:19:44 -0700 (PDT)
Message-ID: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
References: <9986527.24561256620662709.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754774AbZJ0FTp@vger.kernel.org>
In-Reply-To: <9986527.24561256620662709.JavaMail.root@tahiti.vyatta.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One of the root causes of slowness in network usage
was my original choice of power of 2 for hash size, to avoid
a mod operation. It turns out if size is not a power of 2
the original algorithm works fairly well.

On slow cpu; with 10million entries and 211 hash size

Algorithm             Time       Ratio       Max   StdDev
string10             1.271871       1.00     47397   0.01
djb2                 1.406322       1.00     47452   0.12
SuperFastHash        1.422348       1.00     48400   1.99
string_hash31        1.424079       1.00     47437   0.08
jhash_string         1.459232       1.00     47954   1.01
sdbm                 1.499209       1.00     47499   0.22
fnv32                1.539341       1.00     47728   0.75
full_name_hash       1.556792       1.00     47412   0.04
string_hash17        1.719039       1.00     47413   0.05
pjw                  1.827365       1.00     47441   0.09
elf                  2.033545       1.00     47441   0.09
fnv64                2.199533       1.00     47666   0.53
crc                  5.705784       1.00     47913   0.95
md5_string           10.308376       1.00     47946   1.00
fletcher             1.418866       1.01     53189  18.65
adler32              2.842117       1.01     53255  18.79
kr_hash              1.175678       6.43    468517 507.44
xor                  1.114692      11.02    583189 688.96
lastchar             0.795316      21.10   1000000 976.02

How important is saving the one division, versus getting better
distribution.
