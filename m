From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [net-next rfc 1/3] net: avoid high order memory allocation for
 queues by using flex array
Date: Wed, 19 Jun 2013 09:28:53 -0700
Message-ID: <1371659333.3252.329.camel@edumazet-glaptop>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
	 <1371620452-49349-2-git-send-email-jasowang@redhat.com>
	 <1371623518.3252.267.camel@edumazet-glaptop>
	 <20130619091132.GA2816@redhat.com>
	 <1371635763.3252.289.camel@edumazet-glaptop>
	 <20130619154059.GA13735@redhat.com>
	 <1371657511.3252.324.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B729A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	edumazet@google.com, hkchu@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B729A@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 17:06 +0100, David Laight wrote:

> Given the number of places I've seen this code added, why
> not put it in a general helper?

Good luck with that. We had many attempts in the past.

> I also thought that malloc() with GFP_KERNEL would sleep.
> Under what conditions does it fail instead?

For example on 32 bit kernel, LOW memory exhaustion/fragmentation.

vmalloc() has an extra 128MB virtual space (on i386 at least with
standard 3G/1G split)
