From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 0/3] virtio-net: inline header support
Date: Wed, 03 Oct 2012 20:24:47 -0500
Message-ID: <87mx033u74.fsf@codemonkey.ws>
References: <cover.1348824232.git.mst@redhat.com> <87vces2gxq.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, avi@redhat.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:34626 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798Ab2JDBYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 21:24:51 -0400
Received: by obbuo13 with SMTP id uo13so7969003obb.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 18:24:51 -0700 (PDT)
In-Reply-To: <87vces2gxq.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell <rusty@rustcorp.com.au> writes:

> "Michael S. Tsirkin" <mst@redhat.com> writes:
>
>> Thinking about Sasha's patches, we can reduce ring usage
>> for virtio net small packets dramatically if we put
>> virtio net header inline with the data.
>> This can be done for free in case guest net stack allocated
>> extra head room for the packet, and I don't see
>> why would this have any downsides.
>
> I've been wanting to do this for the longest time... but...
>
>> Even though with my recent patches qemu
>> no longer requires header to be the first s/g element,
>> we need a new feature bit to detect this.
>> A trivial qemu patch will be sent separately.
>
> There's a reason I haven't done this.  I really, really dislike "my
> implemention isn't broken" feature bits.  We could have an infinite
> number of them, for each bug in each device.

This is a bug in the specification.

The QEMU implementation pre-dates the specification.  All of the actual
implementations of virtio relied on the semantics of s/g elements and
still do.

What's in the specification really doesn't matter when it doesn't agree
with all of the existing implementations.

Users use implementations, not specifications.  The specification really
ought to be changed here.

Regards,

Anthony Liguori
