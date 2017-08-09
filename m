From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] Revert "vhost: cache used event for better
	performance"
Date: Wed, 9 Aug 2017 07:37:11 +0300
Message-ID: <20170809073422-mutt-send-email-mst@kernel.org>
References: <1501056197-3368-1-git-send-email-jasowang@redhat.com>
	<20170726155435-mutt-send-email-mst@kernel.org>
	<117542fc-eef9-c043-7c9e-daafceb7db4e@redhat.com>
	<6b3a9a98-c095-1729-3528-dd521f136797@redhat.com>
	<20170726190745-mutt-send-email-mst@kernel.org>
	<1501396011.21001.11.camel@klaipeden.com>
	<6698b85c-18f4-17e6-db70-7708692fb761@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	"K. Den" <den@klaipeden.com>, virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <6698b85c-18f4-17e6-db70-7708692fb761@redhat.com>
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

On Wed, Aug 09, 2017 at 10:38:10AM +0800, Jason Wang wrote:
> I think don't think current code can work well if vq.num is grater than
> 2^15. Since all cached idx is u16. This looks like a bug which needs to be
> fixed.

That's a limitation of virtio 1.0.

> > * else if the interval of vq.num is [2^15, 2^16):
> > the logic in the original patch (809ecb9bca6a9) suffices
> > * else (= less than 2^15) (optional):
> > checking only (vring_need_event(vq->last_used_event, new + vq->num, new)
> > would suffice.
> > 
> > Am I missing something, or is this irrelevant?

Could you pls repost the suggestion copying virtio-dev mailing list
(subscriber only, sorry about that, but host/guest ABI discussions
need to copy that list)?

> Looks not, I think this may work. Let me do some test.
> 
> Thanks

I think that at this point it's prudent to add a feature bit
as the virtio spec does not require to never move the event index back.
