From: Brian Haley <brian.haley@hp.com>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Wed, 05 May 2010 21:50:18 -0400
Message-ID: <4BE2205A.3050900@hp.com>
References: <4BE031FA.6040006@hp.com>	<20100504.144647.157477097.davem@davemloft.net>	<4BE1907F.40903@hp.com> <20100505.150008.102542618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, enh@google.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:16570 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846Ab0EFBuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 21:50:22 -0400
In-Reply-To: <20100505.150008.102542618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Brian Haley <brian.haley@hp.com>
> Date: Wed, 05 May 2010 11:36:31 -0400
> 
>> I now see that in Elliot's email, but I think it's incorrect.  The RFC
>> says that setting it to -1 should get you the kernel default, which is
>> now 1.  Without this change, setting it to -1 will get you 64, the
>> old behavior.  If the user wants to, they can always just set it to
>> 64 themselves, that's better than assuming when you set it to -1
>> you're going to get 64.
> 
> It's not 64, it's whatever the per-route metric is.

Not unless that metric's been set via RTAX_HOPLIMIT (and I believe
this is the unicast hop limit value anyways), and that metric
defaults to -1.  Routes added via a Router Advertisement are most
likely going to have a hop limit of 64, but I believe that's only
supposed to apply to unicast.

I *did* search the kernel code and test this before my original reply - it
uses the unicast hop limit from the interface as Elliot originally showed.

~# sysctl net.ipv6.conf.eth2.hop_limit
net.ipv6.conf.eth2.hop_limit = 64

21:04:48.766181 IP6 (hlim 64, next-header UDP (17) payload length: 108)
    fe80::21f:29ff:fef0:2f46.48914 > ip6-allrouters.7639: UDP, length 100

~# sysctl net.ipv6.conf.eth2.hop_limit=63
net.ipv6.conf.eth2.hop_limit = 63

21:05:09.670190 IP6 (hlim 63, next-header UDP (17) payload length: 108)
    fe80::21f:29ff:fef0:2f46.48914 > ip6-allrouters.7639: UDP, length 100

At this point in time I'll gladly implement a per-interface sysctl
to end this discussion.

-Brian
