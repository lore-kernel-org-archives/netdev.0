From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 16:48:11 +0200
Message-ID: <1492699691.3109.11.camel@sipsolutions.net>
References: <1492637460.22185.6.camel@sipsolutions.net>
                                         (sfid-20170419_233114_060429_CAFE85B8) <1492640459.22185.7.camel@sipsolutions.net>
                                 <58F7FA6D.5030000@iogearbox.net>
                         <1492668065.3109.1.camel@sipsolutions.net>
                 <58F8C160.6010905@iogearbox.net>
         <1492697865.3109.7.camel@sipsolutions.net>
                 <58F8C59F.1040009@iogearbox.net>
         <1492698752.3109.8.camel@sipsolutions.net> <58F8C9BA.3090707@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57652 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032934AbdDTOsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 10:48:16 -0400
In-Reply-To: <58F8C9BA.3090707@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-20 at 16:46 +0200, Daniel Borkmann wrote:
> > Hmm. I don't see what "somewhere else" I could possibly have
> > though, given that I want the (kernel-side) context to be "struct
> > sk_buff *" to allow the skb helpers?
> 
> I have not enough context on the wireless side, perhaps could be
> somewhere under skb->dev->ieee80211_ptr or so, iff suitable. 

I don't think I even have skb->dev assigned at this point :)

> But
> it also really doesn't matter much since this is all transparently
> handled in the kernel, meaning these kind of rewrites can still be
> changed at a later point in time, f.e. if it's only 'u64 boottime_ns'
> right now, that could live directly in the cb[] w/o extra pointer,
> and should that grow to more members, then it could be moved behind
> a pointer later on and it still works as-is from the program point
> of view.

Well, there are 48 bytes in the cb already, so doing this would mean
moving two pointer-sized things out, but yeah - as long as we don't add
everything right now we can keep those things that are available to BPF
in the cb and move something else out.

As long as what I described there with the indirect load works, I'm
fine with this, and I can even do data_end pretty easily then.

johannes
