From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Single socket with TX_RING and RX_RING
Date: Wed, 15 May 2013 16:47:42 +0200
Message-ID: <5193A00E.2020507@redhat.com>
References: <loom.20130515T144941-798@post.gmane.org> <51938BAD.5050502@redhat.com> <loom.20130515T152203-727@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?UmljYXJkbyBUdWLDrW8=?= <rtpardavila@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932331Ab3EOOrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 10:47:45 -0400
In-Reply-To: <loom.20130515T152203-727@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2013 03:32 PM, Ricardo Tub=C3=ADo wrote:
> Daniel Borkmann <dborkman <at> redhat.com> writes:
>> On 05/15/2013 02:53 PM, Ricardo Tub=C3=ADo wrote:
>>> Once I tell kernel to export the TX_RING through setsockopt() (see =
code
>>> below) I always get an error (EBUSY) if i try to tell kernel to exp=
ort the
>>> RX_RING with the same socket descriptor. Therefore, I have to open =
an
>>> additional socket for the RX_RING and I require of two sockets when=
 I though
>>> that I would only require of one socket for both TX and RX using mm=
ap()ed
>>> memory.
>>>
>>> Do I need both sockets or am I doing something wrong?
>>
>> The second time you call init_ring() in your code e.g. with TX_RING,=
 where
>> you have previously set it up for the RX_RING. The kernel will give =
you
>> -EBUSY because the packet socket is already mmap(2)'ed.

(if you need an answer, then please do not drop the CC, otherwise it co=
uld be
  that I might not read it)

> Ok, so if I make the following system calls:
>
> void *ring=3DNULL;
> setsockopt(socket_fd, SOL_PACKET, PACKET_RX_RING, p, LEN__TPACKET_REQ=
);
> ring =3D mmap(NULL, ring_len, ring_access_flags, MAP_SHARED, socket_f=
d, 0);
>
> Would I be permitted to use the ring map obtained both for RX and for=
 TX? If
> so, for me it is confusing to use PACKET_RX_RING if I can also TX dat=
a
> through that ring...

I haven't tried it out yet, and currently also do not really have time =
to. But
looking at the mmap code, it seems that the size of the mmap area is ac=
cumulated
for rx and tx ring. However, the header status bits are not really inte=
roperable
with each other. So looks you will need to have two sockets ...
