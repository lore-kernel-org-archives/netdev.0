From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Wed, 6 Jun 2012 21:51:08 +0300
Message-ID: <20120606185107.GA20503@redhat.com>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	<1338972341.2760.3944.camel@edumazet-glaptop>
	<20120606111357.GA15070@redhat.com>
	<1338988210.2760.4485.camel@edumazet-glaptop>
	<20120606144941.GA17092@redhat.com>
	<20120606081432.6b602065@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20120606081432.6b602065@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2012 at 08:14:32AM -0700, Stephen Hemminger wrote:
> On Wed, 6 Jun 2012 17:49:42 +0300
> "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > Sounds good, but I have a question: this realies on counters
> > being atomic on 64 bit.
> > Would not it be better to always use a seqlock even on 64 bit?
> > This way counters would actually be correct and in sync.
> > As it is if we want e.g. average packet size,
> > we can not rely e.g. on it being bytes/packets.
> 
> This has not been a requirement on real physical devices; therefore
> the added overhead is not really justified.
> 
> Many network cards use counters in hardware to count packets/bytes
> and there is no expectation of atomic access there.

BTW for cards that do implement the counters in software,
under xmit lock, is anything wrong with simply taking the xmit lock
when we get the stats instead of the per-cpu trick + seqlock?
