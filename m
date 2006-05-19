From: pravin b shelar <pravin.shelar@calsoftinc.com>
Subject: Re: MultiPath Routing
Date: Fri, 19 May 2006 18:51:56 +0530
Message-ID: <446DC674.60506@calsoftinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	Ravikiran G Thirumalai <kiran@scalex86.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inbox2.nyi.net ([64.147.100.114]:18664 "HELO inbox2.nyi.net")
	by vger.kernel.org with SMTP id S1751111AbWESN0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 09:26:16 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Christian Schmid <webmaster@rapidforum.com> wrote:
>> 
>> Since this seems to be an undocumented feature.... How is this equal-cost multipath supposed to 
>> work? I just want to send outgoing traffic over two gateways. I tried this:
>> 
>> ip route replace default scope global nexthop via 192.168.0.1 dev eth1 weight 100 nexthop via 
>> 192.168.0.100 dev eth1 weight 100
>> 
>> It it doesnt work. It always uses the last for all download-users (around a few hundreds)
>
>Did you enable IP_ROUTE_MULTIPATH_CACHED? If so please disable it
>since it breaks multipath routing for forwarded traffic.

Hi ,
	This was a bug reported by Christian Schmid long back. It is related to equal cost multipath caching on forwarded traffic. The solution suggested for this was 
to disable equal-cost multipath caching. But It does not look like a clean solution.

I investigated the problem further and observed that, If multipath caching is "on" then all route entries are added to the route cache. This leads to selection of same
NIC for all route going through this ( forwarding ) sever. This is because we don't have selection logic for forwarded traffic in multipath caching code.

On digging this list further, I found a patch posted by Herbert, which  disables multipath route cache entry addition for input case.
I tested this patch and everything works fine now.
for the patch ref: http://oss.sgi.com/projects/netdev/archive/2005-04/msg00232.html

So how about including this patch ?

Comments ?

Regards,
Pravin.

