From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 1/4] i40e/i40evf: Add capability exchange for outer checksum
Date: Fri, 7 Apr 2017 06:27:42 -0700
Message-ID: <CAKgT0UdUbz3AoyaHDyMUceS0cY3Li_MMKYJW_U+ZKY1ABYMDrQ@mail.gmail.com>
References: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
 <20170407032325.33374-2-jeffrey.t.kirsher@intel.com> <CAJ3xEMho=LsCOsdbgKHJjTiYB55UR9ZnnZkMAqpM=kH=VGsnrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        David Miller <davem@davemloft.net>,
        Preethi Banala <preethi.banala@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        Alan Brady <alan.brady@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Jacob Keller <jacob.e.keller@intel.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:37062 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755164AbdDGN1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 09:27:43 -0400
Received: by mail-it0-f50.google.com with SMTP id a140so42629079ita.0
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 06:27:43 -0700 (PDT)
In-Reply-To: <CAJ3xEMho=LsCOsdbgKHJjTiYB55UR9ZnnZkMAqpM=kH=VGsnrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 6, 2017 at 11:38 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Fri, Apr 7, 2017 at 6:23 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> From: Preethi Banala <preethi.banala@intel.com>
>>
>> This patch adds a capability negotiation between VF and PF using ENCAP/
>> ENCAP_CSUM offload flags in order for the VF to support outer checksum
>> and TSO offloads for encapsulated packets.
>
> [...]
> -#define I40E_VIRTCHNL_VF_OFFLOAD_    0X00100000
> +#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP         0X00100000
> +#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM    0X00200000
>
> what happens when one of the PF or VF doesn't have this hunk, e.g one
> assumes value X and one assumes value Y for ENCAP_CSUM

The way the capability exchange works is that the VF advertises what
it wants and the PF does an AND of that value and a bitmask of what
the PF supports. The VF then receives the result and has to work with
that. So a legacy PF driver will cause the VF to drop support for
something like this because these bits are not supported.

That way both the PF and VF should know what to expect from each other
in terms of what is supported without it being implied based on the VF
device IDs.

- Alex
