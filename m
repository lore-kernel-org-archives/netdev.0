From: Andrew Morton <akpm@osdl.org>
Subject: Fw: F_SETSIG broken/changed in 2.6 for UDP and TCP sockets?
Date: Mon, 31 May 2004 15:18:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040531151843.7144dfce.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Russell Leighton <russ@elegant-software.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Mon, 31 May 2004 14:45:08 -0400
From: Russell Leighton <russ@elegant-software.com>
To: linux-kernel@vger.kernel.org
Subject: F_SETSIG broken/changed in 2.6 for UDP and TCP sockets?



I have a program that works fine under stock rh9 (2.4.2-8) but has 
issues getting signaled under FedoraCore2 (2.6.5-1.358)
using SETSIG to a Posix RT signal.

The program does the standard:

  /* hook to process */
  if ( fcntl(fdcallback->fd, F_SETOWN, mon->handler_q.thread->pid) == -1 ) {
    aw_log(fdcallback->handler->logger, AW_ERROR_LOG_LEVEL,
       "cannot set owner on fd (%s)",
       strerror(errno));
  }/* end if */

  /* make async */
  if ( fcntl(fdcallback->fd, F_SETFL, (O_NONBLOCK | O_ASYNC) ) == -1 ) {
    aw_log(fdcallback->handler->logger, AW_ERROR_LOG_LEVEL,
       "cannot set async on fd (%s)",
       strerror(errno));
  }/* end if */

  /* hook to signal */
  if ( fcntl(fdcallback->fd, F_SETSIG, AW_SIG_FD) == -1 ) {
    aw_log(fdcallback->handler->logger, AW_ERROR_LOG_LEVEL,
       "cannot set signal on fd (%s)",
       strerror(errno));
  }/* end if */

Under Fedora things work well for raw sockets (much lower latency than 
in 2.4!) but are inconsistent with udp or tcp sockets.

In the udp case, I when I listen for multicast packets my app only 
receives them when I am running a tcpdump (bizarre!).

In the tcp case, I don't get signaled if I do the F_SETSIG on more than 
1 fd.

Any tips on tracking this down would be much appreciated.

Thx

Russ

