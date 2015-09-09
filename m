From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Wed, 09 Sep 2015 16:00:58 -0700
Message-ID: <1441839658.4619.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150909213444.GD20544@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghavendra.kt@linux.vnet.ibm.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35153 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbbIIXBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 19:01:00 -0400
Received: by pacfv12 with SMTP id fv12so23403983pac.2
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 16:00:59 -0700 (PDT)
In-Reply-To: <20150909213444.GD20544@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-09 at 17:34 -0400, Sowmini Varadhan wrote:
> I'm doing some experiments that are trying to simultaneously
> scaling the number of CPUs, and the number of processes 
> and encountering getifaddrs() weaknesses.
> 
> Others have run into similar things in the past,  e.g., 
>   http://lists.openwall.net/netdev/2014/01/23/119
> and more relevant to my experiment: the findings behind 
> the recent commit a3a77372.
> 
> In my case, it looks like getifaddrs() doesnt even use the
> results of IFLA_INET6_STATS or IFLA_INET6_ICMP6STATS- 
> from my scan of glibc, this information is ignored (it only 
> looks at IFLA_STATS).  Moreover, if I hack out  all of 
> snmp_fold_field() (so that it always returns 0),  it helps 
> my cpu utilization and scaling, and no errors are reported.
> 
> So the question is- who uses IFLA_INET6_STATS/IFLA_INET6_ICMP6STATS?
> Is this intended for some ND/ripngd etc daemon?  Doesnt seem to 
> be documented in rtnetlink(7), and couldnt find any users in glibc,
> and google did not find any usage. 

At least ICMP6 stats do not have O(Ncpu) cost anymore,
after commit be281e554e2a4cf2478df7a8b8926c89454bccfa
("ipv6: reduce per device ICMP mib sizes")
