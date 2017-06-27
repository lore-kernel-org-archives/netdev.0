From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next v2 6/6] ixgbe: Add malicious driver detection support
Date: Wed, 28 Jun 2017 00:07:09 +0300
Message-ID: <CAJ3xEMgT62xt=TdFyY9vfRG+eOqvcLT+5m1WSGPtexygyrcB+w@mail.gmail.com>
References: <20170627085131.9831-1-jeffrey.t.kirsher@intel.com>
 <20170627085131.9831-7-jeffrey.t.kirsher@intel.com> <CAJ3xEMiEjGDUatUv47wNTfYPfCVo62+Jjs-xFU3ccN0iJm-5Gg@mail.gmail.com>
 <87618083B2453E4A8714035B62D67992B3E89EA6@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        David Miller <davem@davemloft.net>,
        "Greenwalt, Paul" <paul.greenwalt@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36020 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753295AbdF0VHK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 17:07:10 -0400
Received: by mail-oi0-f43.google.com with SMTP id p187so27371502oif.3
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 14:07:09 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D67992B3E89EA6@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 11:59 PM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:
>>-----Original Message-----
>>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>>Behalf Of Or Gerlitz
>>Sent: Tuesday, June 27, 2017 2:08 AM
>>To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
>>Cc: David Miller <davem@davemloft.net>; Greenwalt, Paul
>><paul.greenwalt@intel.com>; Linux Netdev List <netdev@vger.kernel.org>;
>>nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com
>>Subject: Re: [net-next v2 6/6] ixgbe: Add malicious driver detection
>>support
>>
>>On Tue, Jun 27, 2017 at 11:51 AM, Jeff Kirsher
>><jeffrey.t.kirsher@intel.com> wrote:
>>> From: Paul Greenwalt <paul.greenwalt@intel.com>
>>>
>>> Add malicious driver detection (MDD) support for X550, X550em_a,
>>> and X550em_x devices.
>>>
>>> MDD is a hardware SR-IOV security feature which the driver enables by
>>> default, but can be controlled on|off by ethtool set-priv-flags
>>
>>wait, we have the trusted vf concept, which you implement
>>(ixgbe_ndo_set_vf_trust)
>>so you can enable by default for all vfs and disable it for trusted
>>ones, why create[]  an ixgbe special config knob? IMHO we should max all possible efforts to
>>avoid priv ethtool flags usage.
>
> The "trusted" option was added to allow use cases that were not possible in the
> default driver configuration for SRIOV (promiscuous mode, overriding the MAC).
> While these modes can lead to issues (performance with promisc) they can still
> be useful for certain configurations.
>
> MDD is a completely different type of protection that incorporates checks for
> queue context, Tx descriptors and out-of-bounds DMA/memory access that can
> disrupt the operation of the interfaces. You can read more about it in the X550
> datasheet (section 7.9.4.3 malicious Driver Detection):
> https://www.intel.com/content/www/us/en/embedded/products/networking/ethernet-controller-x550-family-documentation.html
>
> For that reason we do not want to make it part of the "trusted" option.

you can extend the trusted option without breaking the UAPI, currently
it's one bit y/n, but you should have there at least seven more bits
to use.

> In addition MDD is a global setting and cannot be configured per-VF.

can you state more clearly why use think the right configuration knob
here is per driver ethtool private flag?

Or.
