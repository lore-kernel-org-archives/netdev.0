From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v4 2/7] net: remove old tcp_optlen function
Date: Thu, 11 Mar 2010 06:53:06 -0500
Message-ID: <4B98D9A2.8060603@gmail.com>
References: <4B98D592.6040301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B98D592.6040301@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tcp_optlen() function returns a potential *negative* unsigned.

In the only two existing files using the old tcp_optlen() function,
clean up confusing and inconsistent mixing of both byte and word
offsets, and other coding style issues.  Document assumptions.

Quoth David Miller:
    This is transmit, and the packets can only come from the Linux
    TCP stack, not some external entity.

    You're being way too anal here, and adding these checks to
    drivers would be just a lot of rediculious bloat. [sic]

Therefore, there are *no* checks for bad TCP and IP header sizes, nor
any semantic changes.  The drivers should function exactly as existing,
although usage of int should ameliorate the issues.

No response from testers in 21+ weeks.

[removed comment references to commit log]

Requires:
   net: tcp_header_len_th and tcp_option_len_th

Signed-off-by: William.Allen.Simpson@gmail.com
CC: Michael Chan <mchan@broadcom.com>
---
  drivers/net/bnx2.c  |   29 +++++++++++++-----------
  drivers/net/tg3.c   |   60 +++++++++++++++++++++++---------------------------
  include/linux/tcp.h |    5 ----
  3 files changed, 44 insertions(+), 50 deletions(-)
