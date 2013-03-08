From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 0/9] stmmac: update to March_2013 (adding PTP &
 RGMII/SGMII)
Date: Fri, 08 Mar 2013 08:16:24 +0100
Message-ID: <51399048.3070505@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com> <20130307.153456.83724032858548621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	Rayagond K <rayagond@vayavyalabs.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-eu.st.com ([164.129.1.35]:46827 "EHLO
	beta.dmz-eu.st.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267Ab3CHHQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 02:16:41 -0500
In-Reply-To: <20130307.153456.83724032858548621.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David

On 3/7/2013 9:34 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Thu,  7 Mar 2013 11:50:10 +0100
>
>> The PTP support is quite intrusive because it needs to support the extended
>> descriptors used for saving the HW timestamps.
>> These are available in new chip generations, only.
>> So we have actually found useful to use some Kconfig options to
>> surround PTP and extended descriptor support. This approach helped on
>> old platform (embeeded system) where PTP is not supported and where we
>> do not want to pay extra code and check in critical rx/tx paths.
>
> I would prefer run time handling of all of this.
>
> You do not need to put extra checks in the fast paths, instead you
> have different methods that get hooked up into the netdev_ops
> based upon chip capabilities/features/mode.

I don't also like to see ifdef in C code and I always tried to
avoid them in the stmmac.

Indeed I haven't well explained the main reason of this Kconfig. Sorry!

To support PTPv2, we need to change the main descriptor structure
adding new fields (DES4,5,6,7).

    The DESC4 is used for saving some extra information. For this reason
    I added this support in a separate patch.
    The DES6/7 are used for saving HW timestamps.

Unfortunately this new layout breaks the compatibility with old chips.

On new chips that supports the extended descriptors, in fact, we have a
ATDS bit in the DMA MODE register to allow the DMA to use the new
alternate structure.
This is not completely supported in old chips.
For this reason I decided to add these extra Koption.

Welcome advice.

Peppe
>
> Thanks.
