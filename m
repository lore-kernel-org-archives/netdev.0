From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 net-next 0/7] net: foo-over-udp (fou)
Date: Tue, 16 Sep 2014 08:00:18 -0700
Message-ID: <CA+mtBx9d4wkcfmbPXm8m-Uz8K=_hjb3Q_a-0YNY4Yhz4cYoD5Q@mail.gmail.com>
References: <1410750483-3236-1-git-send-email-therbert@google.com>
	<CAJ3xEMjC5PQENzCXS9SNVm6zUVn7pydxf1MLQ57Br1sGjD1ngQ@mail.gmail.com>
	<CA+mtBx_+JxUn4zT+XN8DpQcCoz5Du+QtF1xzLno2m1yCwbr6ow@mail.gmail.com>
	<CAJ3xEMjUKRCOodKs0XF_8xc0WY6=1UH=5STmeLS-a0=ofnSA9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:61023 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393AbaIPPAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 11:00:20 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so5667609igc.7
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 08:00:19 -0700 (PDT)
In-Reply-To: <CAJ3xEMjUKRCOodKs0XF_8xc0WY6=1UH=5STmeLS-a0=ofnSA9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 6:35 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 15, 2014 at 10:15 PM, Tom Herbert <therbert@google.com> wrote:
>> On Mon, Sep 15, 2014 at 11:08 AM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Mon, Sep 15, 2014 at 6:07 AM, Tom Herbert <therbert@google.com> wrote:
>
>>>>   - I really don't expect/want devices to have special support for any
>>>>     of this. Generic checksum offload mechanisms (NETIF_HW_CSUM
>>>>     and use of CHECKSUM_COMPLETE) should be sufficient. RSS and flow
>>>>     steering is provided by commonly implemented UDP hashing. GRO/GSO
>>>>     seem fairly comparable with LRO/TSO already.
>
>>> Again, today NICs are advertizing checksum offloads capability in
>>> enc_hw_features but aren't capable to compute (say) the TCP checksum
>>> of the inner packet regardless of which actual tunneling is used (e.g VXLAN vs
>>> GRE), a bit inconsistent?
>
>> I doubt this is true of all NICs! For instance, a NIC that implements
>> NETIF_F_HW_CSUM should have no problem computing an encapsulated
>> checksums in just about any scenario.
>
> The comment for NETIF_F_HW_CSUM says "Can checksum all the packets" --
> so your interpretation is that NICs supporting that will always report
> CHECKSUM_COMPLETE, OK. But there are bunch of 10/40Gbs NIC drivers
> that don't report the HW_CSUM bit in neither of the ->features and
> ->hw_enc_features, the system should act in a manner that supports them.
>
>> Both, checksum offload and TSO
>> can be supported for arbitrary flavors of UDP encapsulation if NICs
>> use protocol agnostic means as opposed to protocol specific means that
>> require a lot of parsing the packets themselves. Look at the long
>> standing comments in sk_buff about why protocol specific methods like
>> CHECKSUM_UNNECESSARY and NETIF_F_IP_CSUM are bad ideas. With the
>> emergence of encapsulation these are now *really* bad ideas!
>
> So we go and throw away the HW?
>
No, and this is exactly the point! I shouldn't have to throw away all
my deployed hardware to just to get support for the latest
encapsulation protocol du jour. Fortunately, we'll be able to code
around mosts of the limitations of deployed NICs that don't implement
generic mechanisms (with UDP RSS, checksum conversions,  remote
checksum offload). But if you're contemplating a new NIC, *please*
consider implementing generic, protocol agnostic mechanisms.

> Or.
