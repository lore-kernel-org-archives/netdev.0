From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: orphan sockets
Date: Fri, 08 Jul 2011 18:13:14 +0300
Message-ID: <6fa7e62e85e1e2fd069aa9cbf307737a@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42992 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794Ab1GHPSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 11:18:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi

 Just after digging orphan sockets problem, that was causing "Address 
 already in use" for bind(),i found that in documentation is mentioned:

 tcp_orphan_retries - INTEGER
         This value influences the timeout of a locally closed TCP 
 connection,
         when RTO retransmissions remain unacknowledged.
         See tcp_retries2 for more details.

         The default value is 7.
         If your machine is a loaded WEB server,
         you should think about lowering this value, such sockets
         may consume significant resources. Cf. tcp_max_orphans.


 But all servers i have, i notice that  tcp_orphan_retries = 0 by 
 default, i check in code, and found that:
         if (retries == 0 && alive)
                 retries = 8;
 is a bit confusing, that tcp_orphan_retries = 0, is in fact = 8, or to 
 be more exact is 8 if socket has rto < RTO_MAX. But nothing like 7 
 mentioned in documentation, i guess it is wrong?. My english too bad to 
 edit that, but maybe someone will take a look :-)


 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.

