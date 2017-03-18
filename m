From: Daniele Orlandi <daniele@orlandi.com>
Subject: SO_BINDTODEVICE in VRFs not working?
Date: Sat, 18 Mar 2017 02:59:57 +0100
Message-ID: <0ac6f5aa-ca23-0cb0-603f-b30758c4c6c3@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from submission.geniusware.it ([62.212.12.144]:39175 "EHLO
        submission.orlandi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751101AbdCRCRw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 22:17:52 -0400
Received: from localhost (localhost [127.0.0.1])
        by submission.orlandi.com (Postfix) with ESMTP id C67A14C25BA
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 02:59:57 +0100 (CET)
Received: from submission.orlandi.com ([127.0.0.1])
        by localhost (submission.orlandi.com [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id xZSPRSvR5JsK for <netdev@vger.kernel.org>;
        Sat, 18 Mar 2017 02:59:57 +0100 (CET)
Received: from [IPv6:2a02:20:20:cafe::21] (unknown [IPv6:2a02:20:20:cafe::21])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        (Authenticated sender: daniele@orlandi.com)
        by submission.orlandi.com (Postfix) with ESMTPSA id 640C94C25B6
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 02:59:57 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I'm writing an application that should listen on a TCP port bound to an 
inteface in a VRF.

The bind/listen sequence is the following:

   int s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

   char *ifname = "eth1";
   setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, ifname, strlen(ifname)+1);

   struct sockaddr_in addr;
   memset(&addr, 0, sizeof addr);
   addr.sin_family = AF_INET;
   addr.sin_port = htons(555);
   addr.sin_addr.s_addr = inet_addr("0.0.0.0");

   bind(s, (struct sockaddr *)&addr, sizeof(addr));

   listen(s, 5);

The application is confirmed to be bound to the correct interface via "ss":

Netid State    Local Address:Port     Peer Address:Port
tcp   LISTEN   *%eth1:555             *:*

I can ping the interface address finely, however I get an RST whenever I 
try to connect from a remote host:

$ ping 10.10.10.10
PING 10.10.10.10 (10.10.10.10) 56(84) bytes of data.
64 bytes from 10.10.10.10: icmp_seq=1 ttl=64 time=0.758 ms
64 bytes from 10.10.10.10: icmp_seq=2 ttl=64 time=0.350 ms

$ telnet 10.10.10.10 555
Trying 10.10.10.10...
telnet: Unable to connect to remote host: Connection refused

A similar piece of code without setsockopt run via "ip vrf exec" does 
however work!


What am I doing wrong?!?!

Thank you!

-- 
   Daniele Orlandi
