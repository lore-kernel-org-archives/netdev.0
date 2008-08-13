From: Daniel Ng <daniel_ng11@lycos.com>
Subject: Multicast socket behaviour?
Date: Wed, 13 Aug 2008 08:21:58 +0000 (UTC)
Message-ID: <loom.20080813T082132-707@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:43892 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396AbYHMIZW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 04:25:22 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KTBfC-0005sg-QN
	for netdev@vger.kernel.org; Wed, 13 Aug 2008 08:25:19 +0000
Received: from CPE-124-190-96-129.vic.bigpond.net.au ([124.190.96.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 08:25:02 +0000
Received: from daniel_ng11 by CPE-124-190-96-129.vic.bigpond.net.au with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 08:25:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The below C code registers the socket with the multicast group 'HELLO_GROUP':

    mreq.imr_multiaddr.s_addr=inet_addr(HELLO_GROUP);
    mreq.imr_address.s_addr=htonl(INADDR_ANY);

    mreq.imr_ifindex = if_nametoindex("ppp1");

    if (setsockopt(fd,IPPROTO_IP,IP_ADD_MEMBERSHIP,&mreq,sizeof(mreq)) < 0) {
        perror("setsockopt");
        exit(1);
    }

I understand that if 'INADDR_ANY' is used, it is up to the kernel to decide 
what action to take.

>From my experiments, it seems that the interface corresponding to the 
highest '224.0.0.0' entry in the routing table is used.

Would someone please explain why this is so? 

How difficult would it be to have the kernel join the HELLO_GROUP on *all* 
available multicast-capable interfaces? Why isn't this currently implemented?

I'm using 2.6.14.

Cheers,
Daniel


