From: "David S. Miller" <davem@redhat.com>
Subject: Re: SOMAXCONN too low
Date: Wed, 29 Oct 2003 10:43:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031029104350.1db8c94d.davem@redhat.com>
References: <200310290658.h9T6w04k015302@napali.hpl.hp.com>
	<20031029133315.5638f842.ak@suse.de>
	<16287.62792.721035.910762@napali.hpl.hp.com>
	<20031029092220.12518b68.davem@redhat.com>
	<16288.537.258222.601897@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidm@napali.hpl.hp.com, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <16288.537.258222.601897@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Oct 2003 10:08:25 -0800
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> We noticed this problem with a server that uses one thread per CPU
> (pinned).  Why don't you run tux with the "backlog" parameter set to
> 128 and see what happens under heavy load?

Then TuX could be improved too, what can I say?  If the thread taking
in new connections does anything more involved than:

	while (1) {
		fd = accept(listen_fd);
		thr = pick_service_thread();
		spin_lock(new_conn_queue[thr]);
		append(fd, new_conn_queue[thr]);
		spin_unlock(new_conn_queue[thr]);
		wake(thr);
	}

it's broken.  I severly doubt that anyone can show that, when using
the above scheme, their multi-GHZ cpu cannot handle whatever
connection load you put on the system.

The fact that people have written web servers that outperform
TuX and handle the load better is something else to think about.
They existing within the SOMAXCONN limits.
