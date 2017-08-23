From: Vallish Vaidyeshwara <vallish@amazon.com>
Subject: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Wed, 23 Aug 2017 00:10:25 +0000
Message-ID: <1503447027-44399-1-git-send-email-vallish@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eduval@amazon.com>, <anchalag@amazon.com>, <vallish@amazon.com>
To: <davem@davemloft.net>, <shuah@kernel.org>,
        <richardcochran@gmail.com>, <xiyou.wangcong@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v1->v2:
 - Cong Wang pointed out MAX_SCHEDULE_TIMEOUT wraparound, fixed the
   patch 1/2 to accommodate MAX_SCHEDULE_TIMEOUT wait time
 - Changed format of printing total time from float to long in
   selftests patch 2/2

Hello Dave,

Resending the patch series to include netdev mailing list with a
cover letter.

I am submitting 2 patch series to enable hires timer to timeout
datagram sockets (AF_UNIX & AF_INET domain) and test code to test
timeout accuracy on these sockets.

There has been a behavior change in 4.9 kernel with refactoring of Kernel
timer wheel in 4.8. We have a use case wherein our datagram socket
application is sensitive to socket timeout including long timeouts.

One of the test runs with a timeout value of 180 seconds timed out at
190 seconds.
[root@]# ./datagram_sock_timeout 180000
datagram_sock_timeout failed: took 190.00 seconds
[root@]#
The same program when run on a 4.4 kernel would timeout more accurately and
the kernel added slack was not noticeable to user application.

Patch 1: Has core code change of enabling hires timer to timeout datagram
	 socket on AF_UNIX and AF_INET domain
	 Patch 2: Test code to report regression in timeout behavior related to
		 patch 1

Vallish Vaidyeshwara (2):
  net: enable high resolution timer mode to timeout datagram sockets
  selftests/net: add test to verify datagram socket timeout

 net/core/datagram.c                                |  14 ++-
 tools/testing/selftests/net/Makefile               |   3 +-
 .../testing/selftests/net/datagram_sock_timeout.c  | 119 +++++++++++++++++++++
 .../selftests/net/run_datagram_sock_timeout.sh     |  12 +++
 4 files changed, 146 insertions(+), 2 deletions(-)
 create mode 100644 tools/testing/selftests/net/datagram_sock_timeout.c
 create mode 100755 tools/testing/selftests/net/run_datagram_sock_timeout.sh

-- 
2.7.3.AMZN
