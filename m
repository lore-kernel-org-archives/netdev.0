From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: RE: [RFC] TCP burst control
Date: Tue, 6 Jul 2004 20:09:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407070009.i6709wiA026673@ms-smtp-03-eri0.southeast.rr.com>
References: <20040706160447.3c2efffa.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <rhee@ncsu.edu>, <lxu2@ncsu.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@redhat.com>,
        "'Stephen Hemminger'" <shemminger@osdl.org>
In-Reply-To: <20040706160447.3c2efffa.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David and Stephen,

We tested this rate halving. In fact, rate having in fact degrades the
performance quite a bit. We can send you more information about it. Our test
indicates that this feature introduces many timeouts (because of bursts),
and also cause unnecessary cwnd backoff to reduce the transmission
unjustifiably low -- so there are many (I will repeat, many) window and
transmission oscillations during packet losses. We fix this problem
completely using our own special burst control. It is very simple and easy
technique to implement. If you need some data to back up our claims, I will
send you more. Once we implemented our burst control, we don't have any
timeouts and not much fluctuation other than congestion control related.
Currently with rate having, current Linux tcp stack is full of hacks that in
fact, hurt the performance of linux tcp (sorry to say this). Our burst
control, in fact, simplifies a lot of that and makes sure cwnd to follow
very closely to whatever congestion control algorithm is intended it to
behave. The Linux Reno burst control in fact interferes with the original
congestion control (in fact, it tries to do its own), and its performance is
very hard to predict.

Hope this helps.

Injong Rhee, Associate Professor
North Carolina State University
Raleigh, NC 27699
rhee@eos.ncsu.edu, http://www.csc.ncsu.edu/faculty/rhee


-----Original Message-----
From: David S. Miller [mailto:davem@redhat.com] 
Sent: Tuesday, July 06, 2004 7:05 PM
To: Stephen Hemminger
Cc: netdev@oss.sgi.com; rhee@ncsu.edu
Subject: Re: [RFC] TCP burst control

On Tue, 6 Jul 2004 15:58:58 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> When using advanced congestion control it is possible for TCP to decide
that
> it has a large window to fill with data right away. The problem is that if
TCP
> creates long bursts, it becomes unfriendly to other flows and is more
likely
> to overrun intermediate queues.
> 
> This patch limits the amount of data in flight. It came from BICTCP 1.1
but it 
> has been generalized to all TCP congestion algorithms. It has had some
testing,
> but needs to be more widely tested.

Both the New Reno and Westwood+ algorithms implement rate-halving to
solve this problem.

Why can't BICTCP use that instead of this special burst control hack?
