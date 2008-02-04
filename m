From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: LRO ip_summed
Date: Mon, 4 Feb 2008 10:14:23 +0100
Message-ID: <200802041014.23989.ossthema@de.ibm.com>
References: <BAY121-W366A043ECDC160494B1EFAB6320@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1255"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kostya B <bkostya@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:60186 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbYBDJOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 04:14:30 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m149ET2F508334
	for <netdev@vger.kernel.org>; Mon, 4 Feb 2008 09:14:29 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m149ESms606444
	for <netdev@vger.kernel.org>; Mon, 4 Feb 2008 10:14:28 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m149EP0B017826
	for <netdev@vger.kernel.org>; Mon, 4 Feb 2008 10:14:27 +0100
In-Reply-To: <BAY121-W366A043ECDC160494B1EFAB6320@phx.gbl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 03 February 2008 10:48, Kostya B wrote:
> 
> Hi,
> 
> The mail is related to the way LRO manipulates the ip_summed value. Could anybody (author) explain why to overwrite the original value of skb->ip_summed, when it's processing by __lro_proc_skb ?
> E.g. in out: label
> 
> Why not to preserve the coherency of csum status of each incoming to LRO packet, the same way the IP defragmentation does? That means - all skb in descriptor have the same value of ip_summed.
> 

Hi,

I'm not sure if I understand your proposal correctly.
Currently the driver decides via the struct net_lro_mgr
a) which ip_summed value will be used for all aggregated packets
b) which one to use for those packets that can not be aggregated

to a) this one should always be the same. The driver knows whether its HW is
      capable of performing ip checksum checking for this kind of traffic (TCP)

There are two modes: aggregating SKBs or aggregating fragments. 
When fragments are aggregated, there is no SKB with a filled ip_summed available.

Please outline which parts of which mode you suggest to change.

Regards,
Jan-Bernd

