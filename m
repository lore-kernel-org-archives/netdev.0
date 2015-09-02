From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 05/19] ixgbe: Add support for UDP-encapsulated tx
 checksum offload
Date: Wed, 2 Sep 2015 23:56:46 +0300
Message-ID: <CAJ3xEMiARkPi5MWRLJKXx+VA0_gv8_EDKoJAbwWBPdo8-XLLbQ@mail.gmail.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1441156443-33381-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<CALx6S34-mUvQyUQNcVC+o+NeUxWEsCG2GS=Eq++eGqoh=kv8kg@mail.gmail.com>
	<F63CFE64-29E1-484B-B19B-269FAAA9C54B@intel.com>
	<CALx6S36T4tzB5aq3bbKq4DMEumvC4q2YhGscn19se0mGXGe5cQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:35325 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932337AbbIBU4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:56:47 -0400
Received: by oiww128 with SMTP id w128so13582555oiw.2
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:56:46 -0700 (PDT)
In-Reply-To: <CALx6S36T4tzB5aq3bbKq4DMEumvC4q2YhGscn19se0mGXGe5cQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 2, 2015 at 8:38 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Wed, Sep 2, 2015 at 9:46 AM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>>> On Sep 1, 2015, at 8:17 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>
>>> I suspect this is not UDP-encapsulation specific, will it work with
>>> TCP/IP/IP, TCP/IP/GRE etc.?
>>
>> It could do more, but this is what has been tested up to this point.
>>
> Well, please test the those other encapsulations too! It's nice and
> all if they get the benefit, but it's really bad news if these changes
> were to screw them up (i.e. you don't want users of the GRE, IPIP to
> find out that they're now broken).
>
>>> Isn't there anyway the ixgbe could just be made to NETIF_HW_CSUM? That
>>> would be so much more straightforward and support nearly all use cases
>>> without needing to jump through all these hoops.
>>
>> Well, the description says:
>>
>>  ---
>> Note: NETIF_F_HW_CSUM is a superset of NETIF_F_IP_CSUM + NETIF_F_IPV6_CSUM.
>> It means that device can fill TCP/UDP-like checksum anywhere in the packets
>> whatever headers there might be.
>>  ---
>>
>> The device can't do whatever, wherever. There is always a limit to the offset to the inner headers that can be handled, for instance.
>>
> If the device does NETIF_F_HW_CSUM then inner/outer headers are
> irrelevant at least in the non-GSO case. All the device needs to do is
> compute the checksum from start and write the answer at the given
> offset. No protocol awareness needed in the device, no need to parse
> headers on transmit.

Tom, could you elaborate a little further on the
semantics/requirements for devices supporting NETIF_F_HW_CSUM, clearly
(as mentioned in




> I have the same complaint that ixgbe requires a bunch of driver logic
> to offload VXLAN checksum unnecessary instead of just providing
> CHECKSUM_COMPLETE which would work with any encapsulation protocol,
> require no encapsulation awareness in the device, and should be a much
> simpler driver implementation.
