From: Kumiko Ono <kumiko@cs.columbia.edu>
Subject: How can we make more use of memory for TCP properly?
Date: Tue, 13 Jun 2006 17:46:34 -0400
Message-ID: <448F323A.7000005@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs.columbia.edu ([128.59.16.20]:657 "EHLO cs.columbia.edu")
	by vger.kernel.org with ESMTP id S932343AbWFMVqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 17:46:38 -0400
Received: from lion.cs.columbia.edu (IDENT:XrPp306a2n2DEDAyeiB/O0lpP1PKpKIM@lion.cs.columbia.edu [128.59.16.120])
	by cs.columbia.edu (8.12.10/8.12.10) with ESMTP id k5DLkZX6013283
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 17:46:36 -0400 (EDT)
Received: from [128.59.18.194] (compute04.cs.columbia.edu [128.59.18.194])
	by lion.cs.columbia.edu (8.12.9/8.12.9) with ESMTP id k5DLkYBA019983
	for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 17:46:35 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Although I tried to find similar topics in the maling list, I found no 
useful clue. If I overlooked, please let me know the pointer.

I need to increase the value of sysctl_tcp_mem[2] that limit the total 
amount of memory allocated for TCP in order to maintain a number of 
simultateous TCP connections at a server, especially as a TCP server, 
like a web server.

Accorting to TCP man page, the kernel calculates the values of 
sysctl_tcp_mem depending on available physical memory at boot time.
I added 2GB RAM to a machine that had 2GB, and then it has 4GB RAM now. 
However, the value of sysctl_tcp_mem[2] has not changed from 196608 
(pages). The machine is running at Linux 2.6.16.5 i686 Intel(R) 
Pentium(R) 4 CPU 3.06GHz.

When looking through the tcp_init() in tcp.c, I found the value are 
determined with the tcp bind hash size, which reaches a upper cap of 
65536. I understand this upper cap is derived from the maximum of local 
port numbers, which are related to the behavior of TCP client, not that 
of TCP server.

When I manually increased the sysctl_tcp_mem to the double, 393216, and 
tried to establish over 30K TCP connections, the server hung up without 
any error messages of syslog.

Could anbody tell me how to make more use of memory for TCP connections 
properly, without replacing the machine to 64-bit arch.?

Regards,
Kumiko
