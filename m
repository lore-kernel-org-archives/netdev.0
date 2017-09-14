From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v1 0/3] Support for tap user-space access with veth
 interfaces
Date: Thu, 14 Sep 2017 12:12:50 +0800
Message-ID: <64127ea9-7021-6af9-ff00-0f1e57d8c39b@redhat.com>
References: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net
To: sainath.grandhi@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43884 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750750AbdINEMz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 00:12:55 -0400
In-Reply-To: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年09月07日 08:34, sainath.grandhi@intel.com wrote:
> From: Sainath Grandhi <sainath.grandhi@intel.com>
>
> This patchset adds a tap device driver for veth virtual network interface.
> With this implementation, tap character interface can be added only to the
> peer veth interface. Adding tap interface to veth is for usecases that forwards
> packets between host and VMs. This eliminates the need for an additional
> software bridge. This can be extended to create both the peer interfaces as
> tap interfaces. These patches are a step in that direction.
>
> Sainath Grandhi (3):
>    net: Adding API to parse IFLA_LINKINFO attribute
>    net: Abstracting out common routines from veth for use by vethtap
>    vethtap: veth based tap driver
>
>   drivers/net/Kconfig                 |   1 +
>   drivers/net/Makefile                |   2 +
>   drivers/net/{veth.c => veth_main.c} |  80 ++++++++++---
>   drivers/net/vethtap.c               | 216 ++++++++++++++++++++++++++++++++++++
>   include/linux/if_veth.h             |  13 +++
>   include/net/rtnetlink.h             |   3 +
>   net/core/rtnetlink.c                |   8 ++
>   7 files changed, 308 insertions(+), 15 deletions(-)
>   rename drivers/net/{veth.c => veth_main.c} (89%)
>   create mode 100644 drivers/net/vethtap.c
>   create mode 100644 include/linux/if_veth.h
>

Interesting, plan to add vhost support for this? And we can enable 
zerocopy without any worries I think.

Thanks
