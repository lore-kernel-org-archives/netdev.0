From: Ben Greear <greearb@candelatech.com>
Subject: Re: veth regression with =?UTF-8?B?ImRvbuKAmXQgbW9kaWZ5IGlwX3N1bQ==?=
 =?UTF-8?B?bWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3N1bXM=?=
 =?UTF-8?B?IGFzIGdvb2QuIg==?=
Date: Thu, 24 Mar 2016 22:07:10 -0700
Message-ID: <56F4C77E.1010608@candelatech.com>
References: <56F463D6.7080406@candelatech.com> <CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com> <56F4810A.9060904@candelatech.com> <56F49036.8050902@candelatech.com> <56F490B2.3090603@candelatech.com> <CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com> <56F4BFF1.8010806@candelatech.com> <CAKUBDd8ojaAYHZ6L_8HBetqL1P6v9iy9W9ThZwnnzf3-npt-Vg@mail.gmail.com> <CAKUBDd8vwvN4z5gP63ukVjRsgbjKQBZvVHv+bJdQRQgcxD5HGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Vijay Pandurangan <vijayp@vijayp.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:58583 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbcCYFHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 01:07:13 -0400
In-Reply-To: <CAKUBDd8vwvN4z5gP63ukVjRsgbjKQBZvVHv+bJdQRQgcxD5HGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2016 09:45 PM, Vijay Pandurangan wrote:
> Actually, maybe they should be set to CHECKSUM_PARTIAL if we want veth
> to drop the packets if they have bad checksums before they hit the
> application level.

VETH is pretty special in that when you transmit a frame on one
device, it's pair receives it, and unless there is RAM corruption
or bugs in the kernel, then it cannot be corrupted.

But, if you are routing frames from the network to veth
devices, then the original packet could be corrupted, as
described in your patch.

Probably the right behaviour is to keep the old logic for packets
originating from sockets, at least.  I am not sure of a good way
to implement that.

As for testing, I am not sure.  Probably you have to make a good
effort and then just deal with fallout like what I found.  I would guess
that any of us who have ever written an interesting patch have also written
an interesting bug!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
