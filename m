From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix locking
Date: Thu, 11 Sep 2003 16:49:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911164903.63f0010b.davem@redhat.com>
References: <20030906002649.GA32369@server-mrozhavsky.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Rozhavsky <mike@minantech.com>
In-Reply-To: <20030906002649.GA32369@server-mrozhavsky.dyndns.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Sep 2003 17:26:49 -0700
Michael Rozhavsky <mike@minantech.com> wrote:

> I've found two problems with locking in networking code.

Not applied, in both cases a higher order lock guarentees
that nobody else can add elements to the list.

We only need to lock to make sure readers (who don't take
the higher level lock) see a consistent list state.

In the tcp_ipv4.c case, the higher level lock is the listening
socket lock.  In the sit.c case the higher level lock is the
RTNL semaphore.
