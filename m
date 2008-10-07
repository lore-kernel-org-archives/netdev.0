From: "Dan Wong" <dwd178@gmail.com>
Subject: bonding ALB multihomed IP ARP problem
Date: Tue, 7 Oct 2008 11:12:03 -0400
Message-ID: <b6185fb20810070812m45bd203dt5a315b96bd23024e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:23197 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755512AbYJGPMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 11:12:05 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2360496fgg.17
        for <netdev@vger.kernel.org>; Tue, 07 Oct 2008 08:12:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From tcpdump I'm seeing a slave interface reponding to arp request for
a downed multihomed/alias  IP
I've tried bonding mode 0 round robin loading balancing and the
problem doesn't occur.
I'm running RHEL5U1 and using Channel Bonding Driver v3.1.2
Steps to reproduce problem.
1) Setup two servers, server A and B, with bonds mode 6 ALB with
different IP addresses, each bond containing 2 slaves
2) Create Aliases i.e. bond0:1 on server A and B with same Ip addresses
3)  execute the following in loop
     ssh serverA ifdown bond0:1; sleep 5; ssh serverB ifup bond0:1
     sleep 5
     ssh serverB ifdown bond0:1; sleep 5; ssh serverA ifup bond0:1
     sleep 5
After a few iterations, duplicate ip address detected. I've increased
the sleep interval to 30 seconds and still have same problem.
