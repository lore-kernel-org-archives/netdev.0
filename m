From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannels status
Date: Thu, 26 Apr 2007 19:36:15 +0400
Message-ID: <20070426153615.GA8982@2ka.mipt.ru>
References: <d0383f90704260721h7b1ec3ceya781063d9f0ddb8c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Ian Brown <ianbrn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35619 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031289AbXDZPgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 11:36:19 -0400
Content-Disposition: inline
In-Reply-To: <d0383f90704260721h7b1ec3ceya781063d9f0ddb8c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 05:21:35PM +0300, Ian Brown (ianbrn@gmail.com) wrote:
> Hello,
> I read a bit about netchannels in linux (according to Van Jacobson ideas).
> I see that the last version of netchannels (20) is from:
> Fri, 29 Dec 2006.
> http://tservice.net.ru/~s0mbre/blog/2006/12/29#2006_12_29
> 
> My question is : what is the status of the netchannels project ?
> is there intention to try to integrate it into the linux kernel ? Or
> was it abandoned ?

Hmm... Netchannels as is are likely too intrusive changes from my point
of view, so I started to port some of its bits as separated projects -
likely you noticed my patches to replace socket lookup hash tables with
unified trie based storage - idea (and initial implementation) was
copied from netchannels lookup. It does not allow simple wildcard
support (which was a main feature of the netchannels, since they also
supported netfilter (I only implemented NAT)). If I will not be able to
prove that dynamic unified lookup structure is faster than properly sized 
hash table including additional memory allocation/freeing overhead, then
netchannels are not yet ready (since they use even slower algo).
I will continue to work on this interesting idea, but since I do it in
my spare time I can not say any definitive time limits.

Actually since I do not have 10gige testlab I can not prove my
imeplementation does increase processing, since I moved from Van
Jacobson idea quite a bit - he proposed to use different processing
context for usual sockets, I wrote a small TCP/IP stack and moved 
everything in userspace, which showed huge increase in performance but 
mainly because of hugely reduced amount of system calls for small packets.
Initial implementation with socket processing in process context did
show small performance increase in 1gige setup though.

Another great idea derived from netchannels is unified flow cache, which
I'm working on as a socket lookup algo.

So, things move forward, but with different names.
Thanks for interest, feel free to provide ideas and discussion about it.

Feel free to 

> Regards,
> Ian
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
	Evgeniy Polyakov
