From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: fix page refcnt leaking when fail to
	allocate frag skb
Date: Wed, 20 Nov 2013 11:06:27 +0200
Message-ID: <20131120090627.GE19341@redhat.com>
References: <1384848307-7217-1-git-send-email-jasowang@redhat.com>
	<1384869828.8604.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119204909.GA15004@redhat.com>
	<CANJ5vPKmP6rFsBgMGFM8DcuGww7B9PxJMSBkUMHNZOa7LJOA2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CANJ5vPKmP6rFsBgMGFM8DcuGww7B9PxJMSBkUMHNZOa7LJOA2g@mail.gmail.com>
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

On Tue, Nov 19, 2013 at 01:38:16PM -0800, Michael Dalton wrote:
> Great catch Jason. I agree this now raises the larger issue of how to
> handle a memory alloc failure in the middle of receive. As Eric mentioned,
> we can drop the packet and free the remaining (num_buf) frags.
> 
> Michael, perhaps I'm missing something, but why would you prefer
> pre-allocating buffers in this case? If the guest kernel is OOM'ing,
> dropping packets should provide backpressure.
> 
> Also, we could just as easily fail the initial skb alloc in page_to_skb,
> and I think that case also needs to be handled now in the same fashion as
> a memory allocation failure in receive_mergeable.
> 
> Best,
> 
> Mike

Yes I missed this last night. Thanks a lot Eric and Michael for pointing
this out.
