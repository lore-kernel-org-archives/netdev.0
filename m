From: "David S. Miller" <davem@redhat.com>
Subject: Re: MLDv1 /proc/net/igmp6 timer printing [PATCH]
Date: Tue, 18 Nov 2003 22:57:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118225718.25686a30.davem@redhat.com>
References: <OF8D427868.33352D02-ON88256DE3.001A7B55@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF8D427868.33352D02-ON88256DE3.001A7B55@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003 21:55:40 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

>       The problem is the IPv6 multicast address flag
> "MAF_TIMER_RUNNING" is set on a join_group, and cleared
> by a report, but is never set again (e.g., from a query). The timer
> is set and running, but the /proc entry won't show it because it
> only reports the time left on the timer if the flag is set.
>       Fix is to set the flag when the timer is set.

I want to apply this, but I'd like to ask you to fix a related
issue at the same time.  The jiffies reported to userspace by
this multicast code does not convert HZ to USER_HZ, just include
linux/times.h and use jiffies_to_clock_t().

We recently had to fix similar issues in other networking procfs
files.

Thanks David.
