From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next] gre: introduce native tunnel support for
 ERSPAN
Date: Tue, 22 Aug 2017 14:29:42 -0700 (PDT)
Message-ID: <20170822.142942.1549435418952413661.davem@davemloft.net>
References: <1503420028-10791-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mvohra@vmware.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751711AbdHVV3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:29:43 -0400
In-Reply-To: <1503420028-10791-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Tue, 22 Aug 2017 09:40:28 -0700

> The patch adds ERSPAN type II tunnel support.  The implementation
> is based on the draft at [1].  One of the purposes is for Linux
> box to be able to receive ERSPAN monitoring traffic sent from
> the Cisco switch, by creating a ERSPAN tunnel device.
> In addition, the patch also adds ERSPAN TX, so Linux virtual
> switch can redirect monitored traffic to the ERSPAN tunnel device.
> The traffic will be encapsulated into ERSPAN and sent out.
> 
> The implementation reuses tunnel key as ERSPAN session ID, and
> field 'erspan' as ERSPAN Index fields:
> ./ip link add dev ers11 type erspan seq key 100 erspan 123 \
> 			local 172.16.1.200 remote 172.16.1.100
> 
> To use the above device as ERSPAN receiver, configure
> Nexus 5000 switch as below:
> 
> monitor session 100 type erspan-source
>   erspan-id 123
>   vrf default
>   destination ip 172.16.1.200
>   source interface Ethernet1/11 both
>   source interface Ethernet1/12 both
>   no shut
> monitor erspan origin ip-address 172.16.1.100 global
> 
> [1] https://tools.ietf.org/html/draft-foschiano-erspan-01
> [2] iproute2 patch: http://marc.info/?l=linux-netdev&m=150306086924951&w=2
> [3] test script: http://marc.info/?l=linux-netdev&m=150231021807304&w=2
> 
> Signed-off-by: William Tu <u9012063@gmail.com>
> Signed-off-by: Meenakshi Vohra <mvohra@vmware.com>

Applied, thank you.
