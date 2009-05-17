From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: neigh_params_release() usage in net/ipv6/addrconf.c
Date: Sun, 17 May 2009 13:09:52 +0200
Message-ID: <20090517110951.GA3377@ami.dom.local>
References: <8A0B031A-1483-49FD-A4AD-CA4EA87E9359@gmail.com> <4A0F3B0F.2070209@gmail.com> <1A56FDAE-2ECF-4D1C-BAC4-D59594BFB62A@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chase Douglas <chasedouglas.lists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:43386 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbZEQLLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 07:11:25 -0400
Received: by bwz22 with SMTP id 22so2710804bwz.37
        for <netdev@vger.kernel.org>; Sun, 17 May 2009 04:11:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1A56FDAE-2ECF-4D1C-BAC4-D59594BFB62A@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 16, 2009 at 06:57:22PM -0400, Chase Douglas wrote:
> On May 16, 2009, at 6:15 PM, Jarek Poplawski wrote:
...
>> Anyway, it seems you do this vlan on the loopback. If so, there is:
>>
>>         if ((dev->flags & IFF_LOOPBACK) && how == 1)
>>                 how = 0;
>>
>> at least before 2.6.29 kernels, and vlans copy most of the flags.
>> Otherwise, how == 1 should work OK.
>
> I did see that as well. I didn't think that was a fix because I put a  
> printk in there to determine if I was hitting it. Unfortunately, I  
> forgot to copy the new module over before I retested, so I didn't see  
> the message at first. That block was the culprit though.
>
> I grabbed the git commit that included the change to remove the block.  
> So far my patched kernel seems to be working correctly with the patch.

This was probably to fix another problem, and considering there is more
such IFF_LOOPBACK tests, doing vlan on the loopback looks risky to me.

> The reason I'm hesitant to do that can be seen in the case of SLES 10 SP 
> 2. Even though it's 2.6.16, it has so many fixes and backports and SuSE 
> changes that it ends up very different from a stock 2.6.16 kernel. Either 
> way, the SLES 11 kernel is based on 2.6.27.

So, you mean SLES 11.1 according to this:
http://distrowatch.com/table.php?distribution=suse

Anyway, it's "expected" here to verify bug reports against possibly
latest stable vanilla kernels, and considering the amount of your
debugging work, I guess it wouldn't add too much.

Cheers,
Jarek P.
