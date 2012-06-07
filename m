From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [V2 RFC net-next PATCH 2/2] virtio_net: export more statistics
	through ethtool
Date: Thu, 7 Jun 2012 18:15:06 +0100
Message-ID: <1339089306.2770.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120606075217.29081.30713.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120606075217.29081.30713.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

On Wed, 2012-06-06 at 15:52 +0800, Jason Wang wrote:
> Satistics counters is useful for debugging and performance optimization, so this
> patch lets virtio_net driver collect following and export them to userspace
> through "ethtool -S":
> 
> - number of packets sent/received
> - number of bytes sent/received
> - number of callbacks for tx/rx
> - number of kick for tx/rx
> - number of bytes/packets queued for tx
> 
> As virtnet_stats were per-cpu, so both per-cpu and gloabl satistics were
> collected like:
[...]

I would really like to see some sort of convention for presenting
per-queue statistics through ethtool.  At the moment we have a complete
mess of different formats:

bnx2x:    "[${index}]: ${name}"
be2net:   "${qtype}q${index}: ${name}"
ehea:     "PR${index} ${name}"
mlx4_en:  "${qtype}${index}_${name}"
myri10ge: dummy stat names as headings
niu:      dummy stat names as headings
s2io:     "ring_${index}_${name}"
vmxnet3:  dummy stat names as headings
vxge:     "${name}_${index}"; also dummy stat names as headings

And you're introducing yet another format!

(Additionally some of the drivers are playing games with spaces and tabs
to make ethtool indent the stats the way they like.  Ethtool statistics
are inconsistent enough already without drivers pulling that sort of
crap.

I'm inclined to make ethtool start stripping whitespace from stat names,
and *if* people can agree on a common format for per-queue statistic
names then I'll indent them *consistently*.  Also, I would make such
stats optional, so you don't get hundreds of lines of crap by default.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
