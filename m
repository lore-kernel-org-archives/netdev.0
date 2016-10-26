From: Dario Ernst <Dario.Ernst@riverbed.com>
Subject: Question: Why only 1 VTI per src/dest-pair allowed
Date: Wed, 26 Oct 2016 15:45:51 +0200
Message-ID: <8884c89f-81f9-509b-4cde-2c6ca1dfb76a@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([208.70.196.45]:15929 "EHLO
        smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751260AbcJZN4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 09:56:41 -0400
Received: from [100.64.0.230] (unknown [5.158.136.57])
        (using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
        (No client certificate requested)
        by tlssmtp (Postfix) with ESMTP id 285A06B8BF
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 06:45:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I’m currently running into a limitation where I’d like to have multiple 
VTI interfaces with the same source / destination address. It seems like 
that this is not possible by default.

To elaborate a bit on my use-case: I’m trying to set up multiple tunnels 
(SAs) between two endpoints, be it for load-balancing and fail-over, or 
for complex routing in software-defined networking scenarios — or simply 
multiple different peers behind a NAT. I would like to retain the 
flexibility (and debuggability) that having a VTI provides.

I’ve been digging the ip_vti.c and ip_tunnel.c sources a bit — and 
please excuse my kernel-illiteracy, I’m a complete kernel-newbie. I’m 
creating a 2nd VTI through the IOCTL (as »iproute2« does), with the same 
src/dst as an existing VTI, but with a different ikey and okey. The 
condition that seems to break and throw -EEXIST is ip_tunnel_key_match. 
This checks whether TUNNEL_KEY (0x04) is set, however, from what I’ve 
seen only GRE_KEY (0x2000) is set — by vti_tunnel_ioctl. Also, in 
iproute2, I’ve not found that TUNNEL_KEY gets set.

So from what I *think* I’ve read it’s deliberate that the check doesn’t 
actually compare the keys — and thus forbids creating tunnel devices 
with same src/same dst/different key.

Now, my final questions on this is: What is the design decision behind 
this? Is there a finer point that I’m missing? And … is it actually 
sufficient to modify ip_tunnel_key_match to actually compare the keys, 
should they be set?

Thanks for all your great work, and thanks for reading this far :-).
Best Regards,
-Dario Ernst
