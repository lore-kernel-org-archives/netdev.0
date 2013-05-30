From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: updated: kvm networking todo wiki
Date: Thu, 30 May 2013 08:38:17 +0200
Message-ID: <CAJSP0QWY3z_oGaHNwR0=whYgnDCiGLBC+3Z5oM0x5nwN1RQVqg@mail.gmail.com>
References: <20130523085034.GA16142@redhat.com>
	<519F35B7.6010408@redhat.com>
	<20130524113542.GA7046@redhat.com>
	<8738tctrox.fsf@codemonkey.ws>
	<20130524140024.GA12024@redhat.com>
	<87li6yodgq.fsf@rustcorp.com.au>
	<87k3miq6sw.fsf@codemonkey.ws>
	<87r4gpkplc.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, herbert@gondor.hengli.com.au,
	kvm <kvm@vger.kernel.org>, qemu-devel <qemu-devel@nongnu.org>,
	netdev@vger.kernel.org,
	Linux Virtualization <virtualization@lists.linux-foundation.org>,
	Dmitry Fleytman <dmitry@daynix.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f49.google.com ([209.85.128.49]:47890 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967605Ab3E3GiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 02:38:18 -0400
In-Reply-To: <87r4gpkplc.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 7:23 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> Anthony Liguori <anthony@codemonkey.ws> writes:
>> Rusty Russell <rusty@rustcorp.com.au> writes:
>>> On Fri, May 24, 2013 at 08:47:58AM -0500, Anthony Liguori wrote:
>>>> FWIW, I think what's more interesting is using vhost-net as a networking
>>>> backend with virtio-net in QEMU being what's guest facing.
>>>>
>>>> In theory, this gives you the best of both worlds: QEMU acts as a first
>>>> line of defense against a malicious guest while still getting the
>>>> performance advantages of vhost-net (zero-copy).
>>>>
>>> It would be an interesting idea if we didn't already have the vhost
>>> model where we don't need the userspace bounce.
>>
>> The model is very interesting for QEMU because then we can use vhost as
>> a backend for other types of network adapters (like vmxnet3 or even
>> e1000).
>>
>> It also helps for things like fault tolerance where we need to be able
>> to control packet flow within QEMU.
>
> (CC's reduced, context added, Dmitry Fleytman added for vmxnet3 thoughts).
>
> Then I'm really confused as to what this would look like.  A zero copy
> sendmsg?  We should be able to implement that today.
>
> On the receive side, what can we do better than readv?  If we need to
> return to userspace to tell the guest that we've got a new packet, we
> don't win on latency.  We might reduce syscall overhead with a
> multi-dimensional readv to read multiple packets at once?

Sounds like recvmmsg(2).

Stefan
