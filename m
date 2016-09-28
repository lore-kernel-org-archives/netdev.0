From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH RFC 1/3] net: Add dev_set_env_hdr_len to accept envelope
 frames
Date: Wed, 28 Sep 2016 15:09:12 +0900
Message-ID: <5fc51b89-4ab2-f98e-6847-530f4ed4b434@lab.ntt.co.jp>
References: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <1474966541-4420-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <BL2PR07MB2306030D4912AD8F574BAF9D8DCC0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:43430 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751696AbcI1GKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 02:10:02 -0400
In-Reply-To: <BL2PR07MB2306030D4912AD8F574BAF9D8DCC0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/09/27 23:23, Mintz, Yuval wrote:
>> +/* return envelope header length */
>> +static inline int netif_get_env_hdr_len(struct net_device *dev) {
>> +	if (dev->netdev_ops->ndo_set_env_hdr_len)
>> +		return dev->env_hdr_len;
>> +
>> +	if (netif_reduces_vlan_mtu(dev))
>> +		return 0;
>> +
>> +	return 4; /* VLAN_HLEN */
>> +}
> 

Thank you for taking a look at this.

> Why claim that `4' is the default?
> What's the benefit of propagating this value to userspace if
> driver doesn't actually support it?

I'm sorry, this is a leftover from previous draft when I was not aware
of type 2-2 drivers (that do not allow over-MTU-sized packets other than
vlan-tagged ones). Now I'm thinking we should not include
IFLA_ENV_HDR_LEN in response of GETLINK if it is not supported.
I'll delete current logic from next version.

> 
> Assuming this *is* a good default [meaning your analysis indicated
> basically every driver has at least so many octets reserved]
> perhaps we should consider initializing the env_hdr_len in some
> common function [e.g., in setup_ether() next to the mtu] to this value?

I actually tried it first and realized it is difficult, since so many
drivers use their own initializer instead of ether_setup(). Anyway, I'm
going not to expose envhdrlen when it is not supported.

Thanks,
Toshiaki Makita
