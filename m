From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Tue, 03 Mar 2015 20:15:46 -0800
Message-ID: <54F686F2.5010404@gmail.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, netdev@vger.kernel.org,
	davem@davemloft.net
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:46178 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757633AbbCDEP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 23:15:59 -0500
Received: by oiav63 with SMTP id v63so3561919oia.13
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 20:15:58 -0800 (PST)
In-Reply-To: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2015 04:15 PM, roopa@cumulusnetworks.com wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> With the recent addition of the NETIF_F_HW_SWITCH_OFFLOAD flag
> on rocker ports, the second command (bridge link set) below will turn off
> learning in the rocker hw (Scott/Jiri, need some confirmation from
> you that this is indeed a problem and if the below patch is ok).
>
> ip link set dev swp1 master br0
> bridge link set dev swp1 learning off master
> bridge link set dev swp1 learning_sync on self
>
> This patch fixes rocker to ignore learning setting when 'master'
> is set. This makes it possible to set/unset learning in kernel and bridge
> driver independently.
>
> The below command will continue to set learning on in both kernel and rocker
> hw:
> bridge link set dev swp1 learning on
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---

We will at least want this behaviour in the NIC case where the NIC
can support l2 learning and forwarding to VF's or even other ports.
(remind again when a NIC becomes a switch and a switch becomes a NIC?).

In this case you may want to learn in the hardware but in the
hypervisor only support assigned MAC address because this is
controlled by a libvirt/qemu for example.

.John

-- 
John Fastabend         Intel Corporation
