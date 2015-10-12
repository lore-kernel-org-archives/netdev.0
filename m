From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] - gre: add eth_p_teb gro-handler for OVS with gre tunnels
Date: Mon, 12 Oct 2015 16:47:19 -0700
Message-ID: <CAEP_g=9YKT0hcTBmg2AcJb8+uQCVNd1YHEPoT+M3LA4k-cPFPw@mail.gmail.com>
References: <fc84377af8867930138e05c27952d4d4@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>,
	Davem <davem@davemloft.net>, J Kidambi <jkidambi@us.ibm.com>,
	manand@us.ibm.com
To: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33726 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950AbbJLXrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 19:47:40 -0400
Received: by lbbk10 with SMTP id k10so1353310lbb.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 16:47:39 -0700 (PDT)
In-Reply-To: <fc84377af8867930138e05c27952d4d4@imap.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 3:26 PM, Ramu Ramamurthy
<sramamur@linux.vnet.ibm.com> wrote:
>
> Problem:
> --------
>
> When using OVS with GRE tunnels, and GRO is enabled on the nic,
> We find that GRO doesnt really take effect. As a result, TCP stream
> performance on a 10G nic is around 2-3Gbps.
>
> Root Cause:
> -----------
>
> The protocol field set in GRE (by OVS) is ETH_P_TEB.
> The code in gre_gro_receive() (gre_offload.c) calls
> gro_find_receive_by_type() to determine a gro handler for the
> ETH_P_TEB protocol. However, no such protocol is registered
> at the device layer (only ETH_P_IP, ETH_P_IPV6, and mpls related
> protocols are registered). Hence, GRO is skipped.

Why doesn't this work?

commit 9b174d88c257150562b0101fcc6cb6c3cb74275c
Author: Jesse Gross <jesse@nicira.com>
Date:   Tue Dec 30 19:10:15 2014 -0800

    net: Add Transparent Ethernet Bridging GRO support.

    Currently the only tunnel protocol that supports GRO with encapsulated
    Ethernet is VXLAN. This pulls out the Ethernet code into a proper layer
    so that it can be used by other tunnel protocols such as GRE and Geneve.

    Signed-off-by: Jesse Gross <jesse@nicira.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
