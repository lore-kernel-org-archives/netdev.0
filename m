From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 0/5] sctp: use transport hashtable to replace
 association's with rhashtable
Date: Wed, 30 Dec 2015 20:29:03 -0200
Message-ID: <56845AAF.9010204@gmail.com>
References: <1451495979.8255.32.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151230173202.GB16270@localhost.localdomain>
 <1451502680.8255.50.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151230.154425.1221426772185302815.davem@davemloft.net>
 <1451512643.8255.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, mleitner@redhat.com,
	vyasevic@redhat.com, daniel@iogearbox.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36005 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbbL3W3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 17:29:11 -0500
In-Reply-To: <1451512643.8255.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 30-12-2015 19:57, Eric Dumazet escreveu:
> On Wed, 2015-12-30 at 15:44 -0500, David Miller wrote:
>
>> It is more fun than waiting longer for the more limited uses of it to
>> trigger problems.
>>
>> I cannot be convinced that using it in more places in order to find
>> and fix more bugs is a bad thing.
>>
>> I'm sorry if a lot of bug fixes in a short period of time concerns
>> you, but for me that's an even clearer sign that it needs help, and
>> exposing it to more use cases is one of the best forms of help it can
>> get.
>>
>> It also tells me that the people actually working on those fixes, such
>> as Herbert Xu, are motivated and reliable when they are shown properly
>> formed bug reports.
>>
>> I cannot think of a report Herbert and others did not resolve in a
>> timely manner.  They usually add test cases too.
>
>
> I have no doubts we can fix bugs in upstream kernels in a few days (at
> most).
>
> The problem is when a customer is stuck using a distro, with a release
> cycle of extra months after upstream fixes.

If one takes extra months to have a fix delivered to a customer, they 
probably are also months late on security fixes as well, right? That 
would be pretty scary by itself already.

> I had to deal with customers having issues with resolvers hitting the
> netlink/rhashtable bugs, and I can tell you it was not pretty nor funny.
>
> Seeing all these SCTP bugs being currently tracked/fixed (reports from
> Dmitry Vyukov), I am concerned about having to backport fixes into old
> kernels without proper rhashtable if now SCTP relies heavily on
> rhashtable.

This happens with every major change in the kernel. Try backporting 
vxlan fixes to an older kernel, for example, to one without ip_tunnel.

Can't say about the future, but so far none of those bugs were related 
to the hash that we want to replace and they were all small/contained 
patches.

And at least for now, we are not adding new stuff which relies on this 
new hash. It's on a central part of sctp, yes, but somewhat contained. 
Like what happened with vxlan/ip_tunnel, which ended up growing together.

> Hopefully nothing bad will happen.

+1 :)
