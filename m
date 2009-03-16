From: Chuck Lever <chuck.lever@oracle.com>
Subject: IPv6 address printf format specifier
Date: Mon, 16 Mar 2009 12:24:29 -0400
Message-ID: <4B97CD05-9949-485D-987E-A555FCBC2F5A@oracle.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:33922 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267AbZCPQYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 12:24:43 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n2GGRU7Z015004
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2009 16:27:31 GMT
Received: from acsmt706.oracle.com (acsmt706.oracle.com [141.146.40.84])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n2GGOcFa031931
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2009 16:24:39 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NFS and RPC code in the kernel now uses the new printf format  
specifier for IPv6 addresses.  In some cases, the generated address  
string is sent out of the kernel (for example, it is used to build a  
universal address for RPCB_SET requests, and used as the mon_name in  
some SM_MON upcalls to our rpc.statd).

The problem is that outside the kernel, applications generally use  
getnameinfo(3) or inet_ntop(3) to do this conversion.  The library  
follows the RFC suggestion of shortening these address strings by  
replacing the longest series of zeroes in the IPv6 address with "::".

Since the kernel doesn't do that, string comparisons don't work when  
comparing address strings that came from our kernel.  Since these  
address strings appear to other hosts (via the rpcbind registry) this  
is, or could become, an interoperability issue for Linux.

How should I fix this?

1.  Copy glibc's code to the printf logic for %pI6

2.  Copy glibc's code to a special function used only by SM_MON and  
RPCB_SET

3.  Other suggestions or preferences?

Glibc's implementation is Paul Vixie's free version.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
