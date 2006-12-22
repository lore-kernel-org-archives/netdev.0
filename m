From: Hans Henrik Happe <hhh@imada.sdu.dk>
Subject: Re: [Netchannels take19] new netchannel release.
Date: Fri, 22 Dec 2006 01:40:33 +0100
Message-ID: <200612220140.33732.hhh@imada.sdu.dk>
References: <20061220151245.GA19335@2ka.mipt.ru> <20061221163625.GC10845@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from berlioz.imada.sdu.dk ([130.225.128.12]:59179 "EHLO
	berlioz.imada.sdu.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423172AbWLVBGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Dec 2006 20:06:14 -0500
Received: from localhost (localhost [127.0.0.1])
	by localhost.imada.sdu.dk (Postfix) with ESMTP id BF4A662728
	for <netdev@vger.kernel.org>; Fri, 22 Dec 2006 01:40:35 +0100 (CET)
Received: from berlioz.imada.sdu.dk ([127.0.0.1])
 by localhost (berlioz.imada.sdu.dk [127.0.0.1]) (amavisd-new, port 10025)
 with ESMTP id 09271-01 for <netdev@vger.kernel.org>;
 Fri, 22 Dec 2006 00:40:35 +0000 (UTC)
Received: from [192.168.2.100] (unknown [85.218.192.52])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by berlioz.imada.sdu.dk (Postfix) with ESMTP id 3E04262722
	for <netdev@vger.kernel.org>; Fri, 22 Dec 2006 01:40:35 +0100 (CET)
To: netdev@vger.kernel.org
In-Reply-To: <20061221163625.GC10845@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 December 2006 17:36, Evgeniy Polyakov wrote:
> Network channel [1] is peer-to-peer protocol agnostic communication channel
> between hardware and userspace. It uses unified cache to store it's
> channels, allows to allocate buffers for data from userspace mapped area
> or from other preallocated set of pages (like VFS cache). All protocol
> processing happens in process' context.
> 
> Netchannel features:
> o multidimensional wildcards support
> o RCU searching
> o single multidimensional trie for different kinds of dataflows
> o dedicated processing threads with possibility to schedule processing
> 	on different CPUs for those netchannel types which are not acked with
> 	processing context
> o userspace netchannel backend (allows to receive packets to userspace),
> 	which can be used for:
> 		* high-performance sniffers
> 		* tun/tap device replacement
> 		* packet socket replacement (note, that netchannels steal
> 			packets from main stack)
> 		* userspace network stack implementation [2]
> 		* own protocol stack implementaion (from VPN tunnels to
> 			TOE)
> o netfilter netchannel backend (only NAT is supported as the most
> 	interesting user, NAT caches appropriate route, so essentially routing
> 	becomes part of the netchannel trie)
> 
> Multidimensional wildcard is implemented as trie, details can be found
> in development track on the netchannels site [1].
> Some testing was done in 'emulator', i.e. pre-netchannel userspace
> multidimensional trie implementation. Results are here [3].
> 
> 1. Netchannel homepage. 
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel
> 
> 2. Userspace network stack with bechmarks [not yet updated to curent API 
changes].
> New version will be available around Dec 21.
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack
> 
> 3. Multidemnsional trie testing.
> http://tservice.net.ru/~s0mbre/blog/2006/12/02#2006_12_02
> 
> Code is in development state, but I would like to hear comments about
> overall design, features, usefullness for the kernel and get feedback on
> kernel side.

I follow your work with great interest, even though my kernel coding 
experience isn't great. When I get the time I would like to actually try it 
out and provide some feedback.

For now I only follow your progress by reading your web page to get the big 
picture. I must admit it is not easy to get the overall picture from reading 
that, because it is mostly about small details. I think you would get a lot 
more enthusiasm from people, if you described your work top-down. Much of the 
work is about new interfaces and it would be very helpfull with detailed 
descriptions of these. 

I think kevent has arrived to a level of documentation, which makes it 
possible to get the bigger picture before digging into the code.

I know documentation is boring, especially for people who actually put their 
ideas into code (some people like to rant about their ideas forever, without 
actually showing any results). So don't get me wrong; I like your work, but 
if you want more people to get excited about it, I think you need to 
communicate it better.

Anyway, keep up the good work!

Hans Henrik 
