From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH v2 1/1] Workqueue based vhost workers
Date: Mon, 14 Oct 2013 11:27:25 -0700
Message-ID: <20131014112725.34d211aa@nehalam.linuxnetplumber.net>
References: <1381715743-13672-1-git-send-email-bsd@redhat.com>
	<1381715743-13672-2-git-send-email-bsd@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	Michael Tsirkin <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, Bandan Das <bsd@makefile.in>
To: Bandan Das <bsd@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1381715743-13672-2-git-send-email-bsd@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 Oct 2013 21:55:43 -0400
Bandan Das <bsd@redhat.com> wrote:

> +
> +	if (cmwq_worker) {
> +		ret = vhost_wq_init();
> +		if (ret) {
> +			pr_info("Enabling wq based vhost workers failed! "
> +				 "Switching to device based worker instead\n");
> +			cmwq_worker = 0;
> +		} else
> +		  pr_info("Enabled workqueues based vhost workers\n");
> +	}

Why keep two mechanisms (and two potential code paths to maintain)
when the only way vhost_wq_init() can fail is if out of memory.
You may have needed the messages and this during development but for
the final version just do it one way.

If alloc_workqueue fails, then the net_init function should propogate
the error code and fail as well.


