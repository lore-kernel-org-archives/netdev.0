From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: Avoid deadlock situation due to use of xmit_lock
Date: Tue, 6 Dec 2016 20:10:36 +0100
Message-ID: <fa4812b6-fa7c-9fa2-d1c2-c91adab93426@gmx.de>
References: <1480719966-12839-1-git-send-email-LinoSanfilippo@gmx.de>
 <20161206.100607.919832811727709338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:56434 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752364AbcLFTK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 14:10:57 -0500
In-Reply-To: <20161206.100607.919832811727709338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 06.12.2016 16:06, David Miller wrote:
> From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
> Date: Sat,  3 Dec 2016 00:06:04 +0100
> 
>> after stumbling over a potential deadlock situation in the altera driver 
>> (see http://marc.info/?l=linux-netdev&m=148054615230447&w=2), I checked
>> all other ethernet drivers for the same issue and actually found it in 2
>> more, namely stmmac, and sxgbe. Please see the commit messages for a 
>> description of the problem.
>> These 2 patches fix the concerning drivers.
> 
> First of all, I don't want to apply these patches without proper testing
> and ACKs from the individual driver maintainers.
> 
> For both of these drivers, this situation only exists because the TX
> path uses the unnecessary ->tx_lock.  This private lock should be
> removed completely and the driver should use the lock the mid-layer
> already holds in the transmit path and take it in the TX reclaim path
> instead of the private ->tx_lock.
> 

Ok, I will prepare a new set of patches to remove those private locks entirely.

Regards,
Lino
