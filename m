From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: Re: [PATCH] - gre: add eth_p_teb gro-handler for OVS with gre tunnels
Date: Mon, 12 Oct 2015 17:49:13 -0700
Message-ID: <603f81c3c472530ca28263a78576130f@imap.linux.ibm.com>
References: <fc84377af8867930138e05c27952d4d4@imap.linux.ibm.com>
 <CAEP_g=9YKT0hcTBmg2AcJb8+uQCVNd1YHEPoT+M3LA4k-cPFPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>, Netdev <netdev@vger.kernel.org>,
	Davem <davem@davemloft.net>, J Kidambi <jkidambi@us.ibm.com>,
	manand@us.ibm.com
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:52644 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbbJMAtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 20:49:18 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Mon, 12 Oct 2015 18:49:18 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id C9FE53E40041
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 18:49:14 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9D0lwom6095302
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 17:47:58 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9D0nDuv008653
	for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 18:49:14 -0600
In-Reply-To: <CAEP_g=9YKT0hcTBmg2AcJb8+uQCVNd1YHEPoT+M3LA4k-cPFPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-10-12 16:47, Jesse Gross wrote:
> On Mon, Oct 12, 2015 at 3:26 PM, Ramu Ramamurthy
> <sramamur@linux.vnet.ibm.com> wrote:
>> 
>> Problem:
>> --------
>> 
>> When using OVS with GRE tunnels, and GRO is enabled on the nic,
>> We find that GRO doesnt really take effect. As a result, TCP stream
>> performance on a 10G nic is around 2-3Gbps.
>> 
>> Root Cause:
>> -----------
>> 
>> The protocol field set in GRE (by OVS) is ETH_P_TEB.
>> The code in gre_gro_receive() (gre_offload.c) calls
>> gro_find_receive_by_type() to determine a gro handler for the
>> ETH_P_TEB protocol. However, no such protocol is registered
>> at the device layer (only ETH_P_IP, ETH_P_IPV6, and mpls related
>> protocols are registered). Hence, GRO is skipped.
> 
> Why doesn't this work?
> 
> commit 9b174d88c257150562b0101fcc6cb6c3cb74275c
> Author: Jesse Gross <jesse@nicira.com>
> Date:   Tue Dec 30 19:10:15 2014 -0800
> 
>     net: Add Transparent Ethernet Bridging GRO support.
> 
>     Currently the only tunnel protocol that supports GRO with 
> encapsulated
>     Ethernet is VXLAN. This pulls out the Ethernet code into a proper 
> layer
>     so that it can be used by other tunnel protocols such as GRE and 
> Geneve.
> 
>     Signed-off-by: Jesse Gross <jesse@nicira.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks, your commit fixes the same problem in the 4.x kernels. So the 
patch above is redundant.

We are using the 3.x kernels and thats why I could not see your fix in 
my tests.

We/distros would need to backport your fix to 3.x for us to consume it.
