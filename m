From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix locking
Date: Mon, 8 Sep 2003 19:21:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908192115.2f0263f3.davem@redhat.com>
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

The tcp_ipv4.c part is not a bug.  We hold the socket lock on 'sk' and
therefore nobody else can add any entries to lopt->syn_table[]
entries.

We only need to hold the lock during the table update
because _readers_ of the hash table do not take the 'sk'
lock when do traverse the hash.

The sit.c change does look correct, and therefore I'll apply
it after some more review...
