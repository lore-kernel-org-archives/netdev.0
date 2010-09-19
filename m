From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Sun, 19 Sep 2010 14:44:43 +0200
Message-ID: <20100919124443.GJ7350@redhat.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net, kvm@vger.kernel.org,
	arnd@arndb.de, netdev@vger.kernel.org, avi@redhat.com,
	anthony@codemonkey.ws
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 17, 2010 at 03:33:07PM +0530, Krishna Kumar wrote:
> For 1 TCP netperf, I ran 7 iterations and summed it. Explanation
> for degradation for 1 stream case:

Could you document how exactly do you measure multistream bandwidth:
netperf flags, etc?

>     1. Without any tuning, BW falls -6.5%.

Any idea where does this come from?
Do you see more TX interrupts? RX interrupts? Exits?
Do interrupts bounce more between guest CPUs?


>     2. When vhosts on server were bound to CPU0, BW was as good
>        as with original code.
>     3. When new code was started with numtxqs=1 (or mq=off, which
>        is the default), there was no degradation.
> 
>                        Next steps:
>                        -----------
> 1. MQ RX patch is also complete - plan to submit once TX is OK (as
>    well as after identifying bandwidth degradations for some test
>    cases).
> 2. Cache-align data structures: I didn't see any BW/SD improvement
>    after making the sq's (and similarly for vhost) cache-aligned
>    statically:
>         struct virtnet_info {
>                 ...
>                 struct send_queue sq[16] ____cacheline_aligned_in_smp;
>                 ...
>         };
> 3. Migration is not tested.

4. Identify reasons for single netperf BW regression.

5. Test perf in more scenarious:
   small packets
   host -> guest
   guest <-> external
   in last case:
	 find some other way to measure host CPU utilization,
	 try multiqueue and single queue devices

6. Use above to figure out what is a sane default for numtxqs.

> 
> Review/feedback appreciated.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
