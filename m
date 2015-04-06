From: Rick Jones <rick.jones2@hp.com>
Subject: Re: VxLAN system wedge in 4.0.0-rc5+ from davem net-next?
Date: Mon, 06 Apr 2015 15:51:46 -0700
Message-ID: <55230E02.2060204@hp.com>
References: <551F2C20.1060908@hp.com> <20150406190743.GA3969@localhost.localdomain> <5522E5F5.7050605@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:51522 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbbDFWvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 18:51:47 -0400
In-Reply-To: <5522E5F5.7050605@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/06/2015 01:00 PM, Rick Jones wrote:
> On 04/06/2015 12:07 PM, Marcelo Ricardo Leitner wrote:
>> That means you could send/receive some packets on it before the hang,
>> right?
>
> On v3.19 I could send and receive lots of packets without a hang.  I
> could even run netperf through the vxlan tunnel :)
>
> Now that I've addressed my build issue I'm in the midst of a bisect, but
> if someone has faster git-fu I'll not be disappointed if they are able
> to bisect before me.

The git bisect has implicated:

b6a7719aedd7e5c0f2df7641aa47386111682df4 is the first bad commit
commit b6a7719aedd7e5c0f2df7641aa47386111682df4
Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date:   Wed Mar 25 17:07:44 2015 +0100

     ipv4: hash net ptr into fragmentation bucket selection

     As namespaces are sometimes used with overlapping ip address ranges,
     we should also use the namespace as input to the hash to select the ip
     fragmentation counter bucket.

     Cc: Eric Dumazet <edumazet@google.com>
     Cc: Flavio Leitner <fbl@redhat.com>
     Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 fd2a733ad8775b6d5f6096c15187a25515f93812 
7122024878daef58138f67bf47287c3bb8f23caa M	drivers
:040000 040000 89268ed81d87ec7d4f21e45bc22f1f4103fbe829 
759611eb84770f27d8f06f63eaba5e228344cb18 M	include
:040000 040000 7be4960e2db1a2975ee25eddf78f126fc9468662 
e0e86454b5681f6cd9d738f9bc05e7bb828910b4 M	net

I cloned a "fresh" davem net-next tree (before today's accepts and 
message to Linus) which made kernels tagged as 4.0.0-rc6+ and that still 
hung.  When I reverted the commit implicated above, the resulting kernel 
didn't hang when I tried to ping through a vxlan interface.

rick
