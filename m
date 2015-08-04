From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] net: pktgen: don't abuse current->state in
	pktgen_thread_worker()
Date: Tue, 4 Aug 2015 19:08:27 +0200
Message-ID: <20150804170827.GA1264@redhat.com>
References: <20150804163334.GA31842@redhat.com> <20150804164056.GA2758@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Huang Ying <ying.huang@intel.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jan Stancek <jstancek@redhat.com>,
	Jesper Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150804164056.GA2758@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04, Marcelo Ricardo Leitner wrote:
>
> On Tue, Aug 04, 2015 at 06:33:34PM +0200, Oleg Nesterov wrote:
> > Commit 1fbe4b46caca "net: pktgen: kill the Wait for kthread_stop
> > code in pktgen_thread_worker()" removed (in particular) the final
> > __set_current_state(TASK_RUNNING) and I didn't notice the previous
> > set_current_state(TASK_INTERRUPTIBLE). This triggers the warning
> > in __might_sleep() after return.
> >
> > Afaics, we can simply remove both set_current_state()'s, and we
> > could do this a long ago right after ef87979c273a2 "pktgen: better
> > scheduler friendliness" which changed pktgen_thread_worker() to
> > use wait_event_interruptible_timeout().
> >
> > Reported-by: Huang Ying <ying.huang@intel.com>
> > Signed-off-by: Oleg Nesterov <oleg@redhat.com>
>
> Interesting that it didn't happen in my tests yet per description it
> should have. Huang, did you do anything special to trigger this?

Do you have CONFIG_DEBUG_ATOMIC_SLEEP=y ?

Oleg.
