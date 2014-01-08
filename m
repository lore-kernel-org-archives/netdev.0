From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [PATCH net-next v2 1/4] net: allow > 0 order atomic page alloc in
	skb_page_frag_refill
Date: Wed, 8 Jan 2014 16:54:05 -0500
Message-ID: <CAATkVEypFGfXuiBwFacOMjAWyYmLXHiihdpQfJp+CRFEZJagyg@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<20140108180829.GB18162@redhat.com>
	<1389205563.31367.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140108191803.GB18312@redhat.com>
	<1389210371.31367.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jbaron@akamai.com, virtualization@lists.linux-foundation.org,
	Eric Dumazet <edumazet@google.com>, Joshua Hunt <johunt@akamai.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389210371.31367.8.camel@edumazet-glaptop2.roam.corp.google.com>
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

On Wed, Jan 8, 2014 at 2:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-01-08 at 21:18 +0200, Michael S. Tsirkin wrote:
>> On Wed, Jan 08, 2014 at 10:26:03AM -0800, Eric Dumazet wrote:
>> > On Wed, 2014-01-08 at 20:08 +0200, Michael S. Tsirkin wrote:
>> >
>> > > Eric said we also need a patch to add __GFP_NORETRY, right?
>> > > Probably before this one in series.
>> >
>> > Nope, this __GFP_NORETRY has nothing to do with this.
>> >
>> > I am not yet convinced we want it.
>> >
>> > This needs mm guys advice, as its a tradeoff for mm layer more than
>> > networking...
>>
>> Well maybe Cc linux-mm then?
>
> Well, I do not care of people mlocking the memory and complaining that
> compaction does not work.
>
> If these people care, they should contact mm guys, eventually.
>
> Really this is an issue that has nothing to do with this patch set.
>

Actually I have more data on this:

1. __GFP_NORETRY really does help and should go into stable tree.

2. You may want to consider GFP_NOKSWAPD, because even in the
GFP_ATOMIC case you are waking up kswapd to do reclaims on a
continuous basis even when you don't enter direct reclaim.

3. mlocking memory had very little to do with it, that was a
red-herring. I tested out the problem scenario with no mlocks. You
simply need memory pressure from page_cache, and mm ends up constantly
reclaiming and trying to keep another 1-2GB free on our systems (8GB
phys ~4GB left for kernel, ~3GB optimally used for page_cache).

4. I think perhaps using a kmem_cache allocation for this buffer is
the right way to make this work. I am experimenting with a patch to do
this.

-Debabrata

-Debabrata
