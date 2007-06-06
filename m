From: =?ISO-8859-1?Q?Roar_Bj=F8rgum_Rotvik?= <roarbr@tihlde.org>
Subject: Re: sending IPv6 packets via kern_sendmsg
Date: Wed, 06 Jun 2007 08:44:10 +0200
Message-ID: <466657BA.9080903@tihlde.org>
References: <466636DB.8060107@dsto.defence.gov.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anton <Anton.Uzunov@dsto.defence.gov.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [80.239.6.50] ([80.239.6.50]:64730 "EHLO
	ici-lnx1.sici.thales.no" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751239AbXFFH3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 03:29:12 -0400
In-Reply-To: <466636DB.8060107@dsto.defence.gov.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton wrote:
> Hi,
> 
> Following on from a previous (now lost :-)) posting, I have been trying 
> to send out IPv6 packets from a kernel module using the kern_sendmsg() 
> function. Since in theory I need this function to be started in 
> interrupt context (actually, softirq context), but since this is 
> impossible because kern_sendmsg() needs to sleep, I have created a work 
> queue which calls the kern_sendmsg() function separately. The work queue 
> is scheduled from the softirq context (actually, at the moment this 
> happens from a Netfilter hook). The work queue function creates a msghdr 
> structure, fills in a sin6_addr structure, calls sock_create_kern() and 
> then uses this socket to send an IPv6 packet, which consists of a header 
> (struct ipv6hdr *iphdr) and some data following on from this. The above 
> packet is placed in the msghdr structure by setting (after the 
> appropriate initializations):
> msg.msg_iov->iov_base = (char *) ip6hdr;
> msg.msg_iov->iov_len = sizeof( struct ipv6hdr + ntohs( 
> ip6hdr->payload_len ) );

Shouldn't this be:
msg.msg_iov->iov_len = sizeof (struct ipv6hdr) + ntohs (ip6hdr->payload_len);

Seems you use sizeof (nthos (...)), and that seems wrong.

-- 
Roar B. Rotvik
