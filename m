From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Mon, 6 Oct 2014 14:28:14 -0700
Message-ID: <CA+mtBx9HMuMnsmN0rjqV9-5iK9H6b+J8OZQsmmbFHwjm+qW7bQ@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	<CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
	<CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
	<CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
	<CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
	<CAJ3xEMi0biCWTNtLOJ=0HWZYjOWi6pN2bw2=EWajp6XnpoyVRw@mail.gmail.com>
	<CA+mtBx-sP6g9hXAYGfHKCPYkCtjgCFM0srueh1uhoNnC2ACr1g@mail.gmail.com>
	<CAJ3xEMhc-97+3ZDwqXzX2N+=voO4QvJ5_YXn3sp8r8E9YyqotQ@mail.gmail.com>
	<CA+mtBx9=+fGjwJCKpTW5EifmavC6VGnbuJdkc5tqzeEHz+5twA@mail.gmail.com>
	<CAJ3xEMhzxfP3Sqp=_QSQehd2j2s=Gr3B1iO2S--OcoT7VC94nQ@mail.gmail.com>
	<CA+mtBx8-w74f_f9JEfpwH9=Mjr_zaJJAYCMMdYAWdCy-51pzqg@mail.gmail.com>
	<CAJ3xEMgPb9BhvtifmTzy6bS9WDf3jUx6dnx4418KNTjGNPreHQ@mail.gmail.com>
	<CA+mtBx-AW65w7grfb7zTaDKzKQ2n_7JQuLquj1Ayopa4gdiF6Q@mail.gmail.com>
	<CAJ3xEMiLsQ=Wd=461L1Wx0jQ+zivY-Z573+90dD8d7pdUD4Skw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34695 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbaJFV2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:28:15 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so3213748igb.2
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 14:28:14 -0700 (PDT)
In-Reply-To: <CAJ3xEMiLsQ=Wd=461L1Wx0jQ+zivY-Z573+90dD8d7pdUD4Skw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 6, 2014 at 1:22 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Oct 6, 2014 at 8:59 PM, Tom Herbert <therbert@google.com> wrote:
>> On Sun, Oct 5, 2014 at 12:13 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> RX wise, Linux tells the driver that UDP port X would be used for
>>> VXLAN, right? and indeed, it's possible for some HW implementations
>>> not to support RX offloading (checksum) for both VXLAN and NVGRE @ the
>>> same time over the same port. But TX/GRO wise, you're probably
>>> correct. The thing is that from the user POV they need solution that
>>> works for both RX and TX offloading.
>
>> I think from a user POV we want a solution that supports RX and TX
>> offloading across the widest range of protocols. This is accomplished
>> by implementing protocol agnostic mechanisms like CHECKSUM_COMPLETE
>> and protocol agnostic UDP tunnel TSO like we've described. IMO, the
>> fact that we have devices that implement protocol specific mechanisms
>> for NVGRE and VXLAN should be considered legacy support in the stack,
>> for new UDP encapsulation protocols we should not expose specifics in
>> the stack in either by adding a GSO type for each protocol, nor
>> ndo_add_foo_port for each protocol-- these things will not scale and
>> unnecessarily complicate the core stack.
>
> I tend to generally agree to the wind that blows from your writeup, namely:
>
> UDP encapsulation offloads wise, we should pose few general
> requirements to NICs to be implemented by vendors in their tomorrow's
> HW and treat the current generation (these 4-5 drivers with their
> limitations as legacy which should be supported but not state the
> stack overall design).
>
> Still we should seek more ways to reduce the pain/amount of
> not-well-defined-configurations when these drivers are there and the
> stack goes through this upside-down turnaround changes. OTOH you
> didn't accept my SKB coloring suggestion for GSO inspection, and OTOH
> I guess we can live with some sort of generic helper in the form of
> what you suggested, but like it or not, getting rid of
> ndo_add_vxlan_port will simply break things out.
>
> Are we going to have a session on the encapsulation/offloads design @ LPC?
>
yes, I will talk about FOU and GUE implementation. You should
abstracts in the schedule now.

> I think a replay of your LKS presentation along with open discussion
> on how to get there with the legacy requirements could be very
> helpful.
>
>
> Or.
