From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next RFC 3/5] vhost: introduce vhost_add_used_idx()
Date: Wed, 27 Sep 2017 20:59:53 -0400
Message-ID: <CAF=yD-JaivP9=dKp63U3CoReGW4K=W+j4tp_kasHEoMC7rO54A@mail.gmail.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-4-git-send-email-jasowang@redhat.com> <20170926170047-mutt-send-email-mst@kernel.org>
 <c42b7244-6d43-2ce5-46a3-ea70ec9d957f@redhat.com> <20170928015749-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928015749-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> > > @@ -199,6 +199,7 @@ int __vhost_get_vq_desc(struct vhost_virtqueue *vq,
>> > >   void vhost_discard_vq_desc(struct vhost_virtqueue *, int n);
>> > >   int vhost_vq_init_access(struct vhost_virtqueue *);
>> > > +int vhost_add_used_idx(struct vhost_virtqueue *vq, int n);
>> > >   int vhost_add_used(struct vhost_virtqueue *, unsigned int head, int len);
>> > >   int vhost_add_used_n(struct vhost_virtqueue *, struct vring_used_elem *heads,
>> > >                        unsigned count);
>> > Please change the API to hide the fact that there's an index that needs
>> > to be updated.
>>
>> In fact, an interesting optimization on top is just call
>> vhost_add_used_idx(vq, n) instead of n vhost_add_used_idx(vq, 1). That's the
>> reason I leave n in the API.
>>
>> Thanks
>
> Right but you could increment some internal counter in the vq
> structure then update the used index using some api
> with a generic name, e.g.  add_used_complete or something like this.

That adds a layer of information hiding. If the same variable can be
kept close to the computation in a local variable and passed directly
to vhost_add_used_idx_n that is easier to follow.
