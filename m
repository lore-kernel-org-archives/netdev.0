From: Lennert Buytenhek <buytenh@gnu.org>
Subject: [2.6.0, pktgen] divide-by-zero
Date: Wed, 31 Dec 2003 06:13:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031231111316.GA10218@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

When generating packets with pktgen with count=10, I get a divide-by-zero
oops in inject().

Line 273 in net/core/pktgen.c seems unsafe:
	__u64 pps = (__u32)(info->sofar * 1000) / ((__u32)(total) / 1000);

What if total < 1000 ?


cheers,
Lennert
