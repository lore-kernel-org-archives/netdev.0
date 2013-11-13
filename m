From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Wed, 13 Nov 2013 09:18:06 -0800
Message-ID: <1384363086.28458.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
	<1384294885-6444-4-git-send-email-mwdalton@google.com>
	<52833C9B.7070908@redhat.com>
	<1384352348.28458.102.camel@edumazet-glaptop2.roam.corp.google.com>
	<5283AC15.8090706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S.
	Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Ronen Hod <rhod@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <5283AC15.8090706@redhat.com>
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

On Wed, 2013-11-13 at 18:43 +0200, Ronen Hod wrote:

> 
> This initial value, that you do not really want to use, will slowly fade, but it
> will still pretty much dominate the returned value for the first RECEIVE_AVG_WEIGHT(==64)
> samples or so (most ewma implementations suffer from this bug).
> Naturally, it doesn't matter much if you just keep it running forever.
> However, if you will want to restart the learning process more often, which might make
> sense upon changes, then the auto-tuning will be very sub-optimal.

Note that we fill a ring buffer at open time (try_fill_recv()),
all these buffers will be of the minimal size.

By the time we have refilled the ring buffer, EWMA value will be
GOOD_PACKET_LEN.

These sizes are a hint, clamped between 1500 and PAGE_SIZE.

We do not care of very first allocated buffers, they are good enough.

We only care of the million of following allocations.

Also note the EWMA is per queue, not global to the device.

Of course, there is no 'one size' perfect for all usages.
