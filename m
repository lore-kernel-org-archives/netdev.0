From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 14 Jan 2008 09:49:07 -0600
Message-ID: <478B8473.6080506@nortel.com>
References: <478654C3.60806@nortel.com> <2c0942db0801112137k3f3f885ek212d5cbaecb7fea0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ray Lee <ray-lk@madrabbit.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751405AbYANPtr@vger.kernel.org>
In-Reply-To: <2c0942db0801112137k3f3f885ek212d5cbaecb7fea0@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ray Lee wrote:
> On Jan 10, 2008 9:24 AM, Chris Friesen <cfriesen@nortel.com> wrote:

>>After a recent userspace app change, we've started seeing packets being
>>dropped by the ethernet hardware (e1000, NAPI is enabled).  The
>>error/dropped/fifo counts are going up in ethtool:

> Can you reproduce it with a simple userspace cpu hog? (Two, really,
> one per cpu.)
> Can you reproduce it with the newer e1000?

Hmm...good questions and I haven't checked either.  The first one is 
relatively straightforward.  The second is a bit trickier...last time I 
tried the latest e1000 driver the card wouldn't boot (we use netboot).

> Can you reproduce it with git head?

Unfortunately, I don't think I'll be able to try this.  We require 
kernel mods for our userspace to run, and I doubt I'd be able to get the 
time to port all the changes forward to git head.

> If the answer to the first one is yes, the last no, then bisect until
> you get a kernel that doesn't show the problem. Backport the fix,
> unless the fix happens to be CFS. However, I suspect that your
> userpace app is just starving the system from time to time.

It's conceivable that userspace is starving the kernel, but we have do 
about 45% idle on one cpu, and 7-10% idle on the other.

We also have an odd situation where on an initial test run after bootup 
we have 18-24% idle on cpu1, but resetting the test tool drops that to 
the 7-10% I mentioned above.

Based on profiling and instrumentation it seems like the cost of 
sctp_endpoint_lookup_assoc() more than triples, which means that the 
amount of time that bottom halves are disabled in that function also 
triples.
