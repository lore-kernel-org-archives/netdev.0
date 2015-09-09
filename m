From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: IFLA_INET6_[ICMP6]STATS
Date: Wed, 9 Sep 2015 17:34:44 -0400
Message-ID: <20150909213444.GD20544@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghavendra.kt@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29334 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbbIIVer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 17:34:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm doing some experiments that are trying to simultaneously
scaling the number of CPUs, and the number of processes 
and encountering getifaddrs() weaknesses.

Others have run into similar things in the past,  e.g., 
  http://lists.openwall.net/netdev/2014/01/23/119
and more relevant to my experiment: the findings behind 
the recent commit a3a77372.

In my case, it looks like getifaddrs() doesnt even use the
results of IFLA_INET6_STATS or IFLA_INET6_ICMP6STATS- 
from my scan of glibc, this information is ignored (it only 
looks at IFLA_STATS).  Moreover, if I hack out  all of 
snmp_fold_field() (so that it always returns 0),  it helps 
my cpu utilization and scaling, and no errors are reported.

So the question is- who uses IFLA_INET6_STATS/IFLA_INET6_ICMP6STATS?
Is this intended for some ND/ripngd etc daemon?  Doesnt seem to 
be documented in rtnetlink(7), and couldnt find any users in glibc,
and google did not find any usage. 

--Sowmini
