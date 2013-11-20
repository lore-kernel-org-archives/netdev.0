From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next 4/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Wed, 20 Nov 2013 12:36:09 +1030
Message-ID: <87li0jddym.fsf@rustcorp.com.au>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
	<1384294885-6444-4-git-send-email-mwdalton@google.com>
	<528325DC.3050801@redhat.com>
	<1384328458.28458.96.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>, Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1384328458.28458.96.camel@edumazet-glaptop2.roam.corp.google.com>
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

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2013-11-13 at 15:10 +0800, Jason Wang wrote:
>
>> There's one concern with EWMA. How well does it handle multiple streams
>> each with different packet size? E.g there may be two flows, one with
>> 256 bytes each packet another is 64K.  Looks like it can result we
>> allocate PAGE_SIZE buffer for 256 (which is bad since the
>> payload/truesize is low) bytes or 1500+ for 64K buffer (which is ok
>> since we can do coalescing).
>
> It's hard to predict the future ;)
>
> 256 bytes frames consume 2.5 KB anyway on a traditional NIC.
> If it was a concern, we would have it already.
>
> If you receive a mix of big and small frames, there is no win.

Well, that's not quite true.  The device could optimistically look
through the queue a bit for a small buffer; it does not need to consume
in order.  We'd probably want a feature bit for this.

I look forward to your thoughts on what mixing algorithm of different
sizes to use, of course.

Meanwhile, I suspect your patch works well because of 4k pages.  80%
non-GSO packets won't drop the average len below 4k.  On PPC64 with 64k
pages, that's not true.

I wonder if "last used len" would work about as well; it really might if
we had a smarter device...

Cheers,
Rusty.
