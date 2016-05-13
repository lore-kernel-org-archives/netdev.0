From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] net: cls_u32: Add support for skip-sw
 flag to tc u32 classifier.
Date: Fri, 13 May 2016 11:15:36 -0700
Message-ID: <573619C8.2040905@gmail.com>
References: <1463098103-2434-1-git-send-email-sridhar.samudrala@intel.com>
 <1463098103-2434-3-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Sridhar Samudrala <sridhar.samudrala@intel.com>,
	john.r.fastabend@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34205 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbcEMSPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 14:15:50 -0400
Received: by mail-pa0-f67.google.com with SMTP id yl2so9020111pac.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 11:15:49 -0700 (PDT)
In-Reply-To: <1463098103-2434-3-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-12 05:08 PM, Sridhar Samudrala wrote:
> On devices that support TC U32 offloads, this flag enables a filter to be
> added only to HW. skip-sw and skip-hw are mutually exclusive flags. By
> default without any flags, the filter is added to both HW and SW, but no
> error checks are done in case of failure to add to HW. With skip-sw,
> failure to add to HW is treated as an error.
> 
> Here is a sample script that adds 2 filters, one with skip-sw and the other
> with skip-hw flag.
> 
>    # add ingress qdisc
>    tc qdisc add dev p4p1 ingress
> 
>    # enable hw tc offload.
>    ethtool -K p4p1 hw-tc-offload on
> 
>    # add u32 filter with skip-sw flag.
>    tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
>       handle 800:0:1 u32 ht 800: flowid 800:1 \
>       skip-sw \
>       match ip src 192.168.1.0/24 \
>       action drop
> 
>    # add u32 filter with skip-hw flag.
>    tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
>       handle 800:0:2 u32 ht 800: flowid 800:2 \
>       skip-hw \
>       match ip src 192.168.2.0/24 \
>       action drop
> 
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---

Looks good to me thanks for doing this.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
