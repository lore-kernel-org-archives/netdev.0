From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: sky2: tx hang on dual-port Yukon XL when rx csum disabled
Date: Mon, 28 Jan 2008 13:21:56 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5204481E71@orsmsx418.amr.corp.intel.com>
References: <479E2247.8080109@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Tony Battersby" <tonyb@cybernetics.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60003 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120AbYA1VV6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 16:21:58 -0500
Content-class: urn:content-classes:message
In-Reply-To: <479E2247.8080109@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tony Battersby wrote:
> I am experiencing network tx hangs on a dual-port SK-9E22 with sky2 in
> 2.6.24.  The problem is triggered by both ports transmitting at high
> speed simultaneously.  This problem is 100% quickly reproducible. 
> Here is the setup:
> 
> PC #1 with Intel PRO/1000 NIC:
> e1000 IP address 192.168.1.1
> running iperf -s
> 
> PC #2 with Intel PRO/1000 NIC:
> e1000 IP address 192.168.2.1
> running iperf -s
> 
> PC #3 with SysKonnect SK-9E22 (dual-port copper PCI-express)
> sky2 IP address 192.168.1.2
> sky2 IP address 192.168.2.2
> 
> So basically, I have two PCs with Intel PRO/1000 NICs running "iperf
> -s".  Each of these Intel NICs is directly cabled to one of the two
> ports of the SysKonnect NIC.

make sure to disable the default Linux arp behavior for this kind of
test on PC3 by*
[root@real-server]# echo 1 > /proc/sys/net/ipv4/conf/all/arp_filter
[root@real-server]# echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_filter
[root@real-server]# echo 1 > /proc/sys/net/ipv4/conf/eth1/arp_filter

*see http://linux-ip.net/html/ether-arp.html
