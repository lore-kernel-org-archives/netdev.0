From: "David S. Miller" <davem@redhat.com>
Subject: Re: route cache DoS testing and softirqs
Date: Tue, 30 Mar 2004 14:22:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040330142210.080dbe38.davem@redhat.com>
References: <20040329222926.GF3808@dualathlon.random>
	<200403302005.AAA00466@yakov.inr.ac.ru>
	<20040330211450.GI3808@dualathlon.random>
	<20040330133000.098761e2.davem@redhat.com>
	<20040330213742.GL3808@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, dipankar@in.ibm.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se, paulmck@us.ibm.com,
        akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20040330213742.GL3808@dualathlon.random>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Mar 2004 23:37:42 +0200
Andrea Arcangeli <andrea@suse.de> wrote:

> that means nothing runs in ksoftirqd for Dipankar, so he cannot be using
> NAPI.
> 
> Either that or I'm misreading his numbers, or his stats results are wrong.

If these numbers are with your "if (ksoftirqd_pending()) return;" thing
at the top of do_softirq() then I must agree with you.

Otherwise, keep in mind what I said, and also as Robert mentioned every
single local_bh_enable() is going to call do_softirq() if the count falls
to zero.
