From: Jiri Slaby <jirislaby@gmail.com>
Subject: epoll broken [was: mmotm 2011-01-25-15-47 uploaded]
Date: Thu, 03 Feb 2011 08:39:43 +0100
Message-ID: <4D4A5BBF.20806@gmail.com>
References: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org,
	ML netdev <netdev@vger.kernel.org>, davidel@xmailserver.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/26/2011 12:48 AM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2011-01-25-15-47 has been uploaded to

Hi, the network daemons are broken here. cupsd and httpd children
segfault too often without servicing requests. It's a regression against
mmotm 2011-01-06-15-41.

It's epoll after it dies:
17836 epoll_create(8192)                = 3
...
17836 accept(7, {sa_family=AF_FILE, NULL}, [2]) = 11
17836 getsockname(11, {sa_family=AF_FILE,
path="/var/run/cups/cups.sock"}, [26]) = 0
17836 setsockopt(11, SOL_TCP, TCP_NODELAY, [1], 4) = -1 EOPNOTSUPP
(Operation not supported)
17836 fcntl(11, F_GETFD)                = 0
17836 fcntl(11, F_SETFD, FD_CLOEXEC)    = 0
17836 epoll_ctl(3, EPOLL_CTL_ADD, 11, {EPOLLIN, {u32=379708832,
u64=140428630418848}}) = 0
17836 epoll_wait(3, {{EPOLLIN, {u32=379708832, u64=140428630418848}}},
8192, 1000) = 1
17836 recvfrom(11, "P", 1, MSG_PEEK, NULL, NULL) = 1
17836 poll([{fd=11, events=POLLIN}], 1, 10000) = 1 ([{fd=11,
revents=POLLIN}])
17836 recvfrom(11, "POST / HTTP/1.1\r\nContent-Length:"..., 2048, 0,
NULL, NULL) = 771
17836 sendto(11, "HTTP/1.1 100 Continue\r\n\r\n", 25, 0, NULL, 0) = 25
17836 epoll_wait(3, {{EPOLLIN, {u32=379708832, u64=140428630418848}},
{0, {u32=0, u64=0}} .............. {0, {u32=0, u64=0}}, ?}
0x7fb816996660, 8192, 0) = 379151968
17836 --- SIGSEGV (Segmentation fault) @ 0 (0) ---
17836 +++ killed by SIGSEGV +++

The parameter, the same as the retval, seems to be bogus.

Is it known (fixed in newer kernels)?

thanks,
-- 
js
