From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] bridge: netlink: check vlan_default_pvid range
Date: Mon, 15 May 2017 15:05:38 +0300
Message-ID: <0ba60aa7-9791-a023-0d5b-a8bc0223fffd@cumulusnetworks.com>
References: <20170515110819.11847-1-tobias.jungel@bisdn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Tobias Jungel <tobias.jungel@bisdn.de>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38254 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754329AbdEOMFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 08:05:39 -0400
Received: by mail-wm0-f44.google.com with SMTP id v15so44148189wmv.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 05:05:38 -0700 (PDT)
In-Reply-To: <20170515110819.11847-1-tobias.jungel@bisdn.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/15/17 2:08 PM, Tobias Jungel wrote:
> Currently it is allowed to set the default pvid of a bridge to a value
> above VLAN_VID_MASK (0xfff). This patch checks the passed pvid and
> disables the pvid in case it is out of bounds.
> 
> Reproduce by calling:
> 
> [root@test ~]# ip l a type bridge
> [root@test ~]# ip l a type dummy
> [root@test ~]# ip l s bridge0 type bridge vlan_filtering 1
> [root@test ~]# ip l s bridge0 type bridge vlan_default_pvid 9999
> [root@test ~]# ip l s dummy0 master bridge0
> [root@test ~]# bridge vlan
> port	vlan ids
> bridge0	 9999 PVID Egress Untagged
> 
> dummy0	 9999 PVID Egress Untagged
> ---
>   net/bridge/br_vlan.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 

Good catch, but this is not the right fix. Default pvid of 0 disables the
default pvid, but a wrong pvid should result in -EINVAL return instead of
0. Take a look how the parent default pvid function handles this case
(br_vlan_set_default_pvid).

Also please add a sign off and a proper Fixes tag.
For more information about submitting patches you can check
Documentation/SubmittingPatches

Thanks,
  Nik
