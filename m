From: Tom Herbert <therbert@google.com>
Subject: Re: some failures with vxlan offloads..
Date: Sun, 26 Oct 2014 18:23:07 -0700
Message-ID: <CA+mtBx9g6MYpFv83av1YdRpZRBcBKvsqzSnhs5C7iV+kP8cWDA@mail.gmail.com>
References: <544CF8E3.8070207@mellanox.com>
	<CA+mtBx-Jp5Kps5WycYwN0PuyXLDtGM0s8USxdQoSLPRDVS19xw@mail.gmail.com>
	<CAJ3xEMi6UuCT+6iriX02qjS6trhEaoYh39UBL+p_i995MvZc2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:39423 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728AbaJ0BXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 21:23:08 -0400
Received: by mail-ig0-f170.google.com with SMTP id hn18so4958522igb.1
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2014 18:23:07 -0700 (PDT)
In-Reply-To: <CAJ3xEMi6UuCT+6iriX02qjS6trhEaoYh39UBL+p_i995MvZc2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 26, 2014 at 3:23 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Sun, Oct 26, 2014 at 5:29 PM, Tom Herbert <therbert@google.com> wrote:
>> On Sun, Oct 26, 2014 at 6:36 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>
>>> In the cases where it breaks I can see
>>>         UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789
>>> ulen 726
>>> prints from __udp4_lib_rcv() in the kernel log of the node where offloads
>>> are OFF, where the bad packet is sent from the host where offloading is
>>> enabled. I guess the packet is just dropped:
>
>> Can you determine what the TSO HW engine is setting in UDP checksum
>> field? tcpdump -vv might be able to show this. The symptoms seem to
>> indicate that it may not be zero.
>
> Thanks for the quick response. I'll check what is placed in the UDP
> checksum field for packets that went through the offloading HW and let
> you know.
>
> BTW, if following the direction you proposed, I wonder why this works
> (e.g the kernel doesn't drops the encapsulated TCP packets) when both
> sides are offloaded?
>
I'm just speculating, but the device may be returning checksum
unnecessary for the UDP checksum without actually checking it.
Technically, VXLAN RFC7348 allows an implementation to ignore the UDP
checksum, although this clearly violates RFC1122 UDP checksum
requirements. In the stack we now checksum all non-zero checksums
including UDP checksum in VXLAN if it's not marked
checksum-unnecessary.

Tom


> Tomorrow (Monday) I am OOO so will be able to do these further tests Tuesday.
>
> Or.
