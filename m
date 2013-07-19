From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: strange crashes in tcp_poll() via epoll_wait
Date: Fri, 19 Jul 2013 09:24:17 -0700
Message-ID: <1374251057.26476.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Al

I tried to debug strange crashes in tcp_poll() called from
sys_epoll_wait() -> sock_poll()

The symptom is that sock->sk is NULL and we therefore dereference a NULL
pointer.

It's really rare crashes but still, it would be nice to understand where
is the bug. Presumably latest kernels would crash in sock_poll() because
of the sk_can_busy_loop(sock->sk) call.

We do test sock->sk being NULL in sock_fasync(), but epoll should be
safe because of existing synchronization (epmutex) ?

Any idea?

Thanks !
