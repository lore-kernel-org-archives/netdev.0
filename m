From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] virtio-net: alloc big buffers also when guest can
 receive UFO
Date: Thu, 13 Feb 2014 11:02:13 +0800
Message-ID: <52FC35B5.6000900@redhat.com>
References: <1392183808-16789-1-git-send-email-jasowang@redhat.com> <20140212115901.GC23006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, virtio-dev@lists.oasis-open.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtio-dev-return-379-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
In-Reply-To: <20140212115901.GC23006@redhat.com>
List-Id: netdev.vger.kernel.org

On 02/12/2014 07:59 PM, Michael S. Tsirkin wrote:
> On Wed, Feb 12, 2014 at 01:43:28PM +0800, Jason Wang wrote:
>> > We should alloc big buffers also when guest can receive UFO
>> > pakcets. Otherwise the big packets will be truncated when mergeable rx
>> > buffer is disabled.
> Not truncated, they will be dropped.
>

Why dropped? We enable the ufo on tap0 if VIRTIO_NET_F_GUEST_UFO is
negotiated. So skb was queued on the receive queue. But since the
receive buffer is small, it will be truncated during tun_put_user().
