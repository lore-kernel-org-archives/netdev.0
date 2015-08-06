From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next 07/15] i40e/i40evf: Add TX/RX outer UDP checksum
 support for X722
Date: Thu, 6 Aug 2015 08:12:30 -0700
Message-ID: <CALx6S35mE624Yi9m2hg=7i5YQdeH_7491LvZZmNvSuTr3Y1FHA@mail.gmail.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1438818735-38115-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<CALx6S37TdC_ykVSi2SfLpX8TyNDs+XAgOxQzxgK-x8dKzb_nAA@mail.gmail.com>
	<20150805173830.00001a1c@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38292 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbbHFPMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 11:12:31 -0400
Received: by iggf3 with SMTP id f3so13426719igg.1
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 08:12:30 -0700 (PDT)
In-Reply-To: <20150805173830.00001a1c@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 5, 2015 at 5:38 PM, Jesse Brandeburg
<jesse.brandeburg@intel.com> wrote:
> On Wed, 5 Aug 2015 17:13:21 -0700
> Tom Herbert <tom@herbertland.com> wrote:
>
>> On Wed, Aug 5, 2015 at 4:52 PM, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>> > From: Anjali Singhai Jain <anjali.singhai@intel.com>
>> >                 if (vsi->back->flags & I40E_FLAG_WB_ON_ITR_CAPABLE)
>> >                         tx_ring->flags = I40E_TXR_FLAGS_WB_ON_ITR;
>> > +               if (vsi->back->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE)
>> > +                       tx_ring->flags |= I40E_TXR_FLAGS_OUTER_UDP_CSUM;
>>
>> Just curious... is there a difference between enabling the outer UDP
>> checksum (of a tunnel) and just enabling checksum offload for UDP
>> packets?
>
> Yes, the hardware knows the difference (or we actually tell it
> the difference) between a UDP packet and a tunnel inside a UDP
> packet.

There should be no difference between handling the UDP checksum for
tunneling versus a non-tunnel packet with a UDP checksum. While VXLAN
(RFC7348) allows for non-zero checksums to be not be verified, this
fundamentally violates UDP specification (RFC1122). Neither is there
any API that allows a driver to indicate to the stack that a non-zero
UDP checksum is accepted but not verified, using checksum unnecessary
for that would also be incorrect.

Not to belabor the point, but if devices provide checksum-complete
this complexity in drivers and devices needing to parse specific UDP
encapsulations goes away.

Tom
