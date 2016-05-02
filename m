From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2 1/9] net: Disable segmentation if checksumming
 is not supported
Date: Mon, 2 May 2016 10:28:41 +0300
Message-ID: <CAJ3xEMjqA=QobVc4+gEXXW0FAACqGoqi3b8dwvif6CxXXh5TmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <michael.chan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36103 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632AbcEBH2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 03:28:42 -0400
Received: by mail-io0-f177.google.com with SMTP id u185so188012271iod.3
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 00:28:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 2, 2016 at 5:16 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Sun, May 1, 2016 at 1:30 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Sat, Apr 30, 2016 at 1:43 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>> In the case of the mlx4 and mlx5 driver they do not support IPv6 checksum
>>> offload for tunnels.
>>
>> Alex,
>>
>> To clarify, when you say "not support IPv6 checksum for tunnels", you
>> refer to the offloading of the outer or inner checksum?
>
> In the case of mlx4 it was an issue with both inner and outer due to
> IPv6 checksum.  The issue was that the feature was not exposed and yet
> the stack was attempting to make use of it in various ways.  The fixes
> that resolved the issues are in patches 1 and 4.  If we wanted to we
> could move those to net, but then it would be difficult to test the
> existing patches on the mlx4 until the net tree containing those
> patches was merged back in.
>
>> Still (me and I think also Tariq from our driver team) catching up on
>> the series, the primitives and conventions you are introducing using
>> and how this applies on mlx5. I saw that Saeed acked the the mlx5e
>> patches (7 and 8).
>
> The concept for all this is pretty simple.  What I am doing is
> restricting TSO so that we have a fixed size that is used for all
> outgoing frames.

excellent... how exactly this is done? I wasn't sure if this is
existing facility in the kernel and which or somehow introduced now
(where)? would appreciate if you can drop a note on that.

> Then we precompute the outer headers and use those
> values when performing GSO.  By doing this we can populate the UDP
> checksum field instead of forcing it to 0 which allows us to perform
> TSO for tunnels with outer checksums.

now.. understood.

>> Specifically, the mlx4 patches are practically fixes so if they don't
>> land in 4.7 via net-next we can get them there through net, lets give
>> us the few more days needed to catch up from our side.

> Actually the mlx4 specific portion of these patches are not really
> fixes, they are enabling features.  Specifically IPv6 checksum, TSOv6,
> and TSO for VXLAN tunnels with outer checksums.  It is patches 1 and 4
> that contain the fix and it likely applies to more than just the mlx4
> driver as I believe there is a qlogic driver with a similar feature
> flag layout.  If we want we could recommend those patches for stable

All makes sense, I will be able to ack the mlx4 patches tomorrow or
the latest Wed so we are just fine for 4.7 - I don't see urgency to
put them on 4.6

Or.
