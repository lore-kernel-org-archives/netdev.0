From: Saurabh <saurabh.mohan@vyatta.com>
Subject: [net-next PATCH 00/02] net/ipv4: Add support for new tunnel type
 VTI.
Date: Fri, 8 Jun 2012 10:32:25 -0700
Message-ID: <20120608173225.GA11928@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36152 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753709Ab2FHRcg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2012 13:32:36 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 9791D14103AC
	for <netdev@vger.kernel.org>; Fri,  8 Jun 2012 10:32:36 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cINW6rQ3zKFA for <netdev@vger.kernel.org>;
	Fri,  8 Jun 2012 10:32:35 -0700 (PDT)
Received: from localhost (eng-dhcp-126.vyatta.com [10.3.0.126])
	by mail.vyatta.com (Postfix) with ESMTPSA id 5B8B814103AB
	for <netdev@vger.kernel.org>; Fri,  8 Jun 2012 10:32:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Introduction:
Virtual tunnel interface is a way to represent policy based IPsec tunnels as virtual interfaces in linux. This is similar to Cisco's VTI (virtual tunnel interface) and Juniper's representaion of secure tunnel (st.xx). The advantage of representing an IPsec tunnel as an interface is that it is possible to plug Ipsec tunnels into the routing protocol infrastructure of a router. Therefore it becomes possible to influence the packet path by toggling the link state of the tunnel or based on routing metrics.

Overview:
Natively linux kernel does not support ipsec as an interface. Also secure interface assume a ipsec policy 4 tupple of {dst-ip-any, src-ip-any, dst-port-any, src-port-any}. Applying this 4 tuple in linux would result in all traffic matching the ipsec policy. What is needed is a tunnel distinguisher. The linux kernel skbuff has fwmark which is used for policy based routing (PBR). Linux kernel version 2.6.35 enhanced SPD/SADB to use fwmark as part of the IPsec policy. Strongswan has also introduced support for this kernel feature with version 4.5.0. We can therefore use the fwmark as the distinguisher for tunnel interface. We can also create a light weight tunnel kernel module (vti) to give the notion of an interface for rest of the kernel routing system. The tunnel module does not do any enc
 apsulation/decapsulation. The kernel's xfrm modules still do the esp encryption/decryption.

Usage:
ip tunnel add sti15 mode vti remote 12.0.0.1 local 12.0.0.3 ikey 15
or
ip link add sti15 type vti key 15 remote 12.0.0.1 local 12.0.0.3

Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>
Reviewed-by: Stephen Hemminger <shemminger@vyatta.com>

---
