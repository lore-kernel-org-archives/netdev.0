From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [1/3] 2.6.21-rc6: known regressions
Date: Sat, 14 Apr 2007 17:07:55 +1200
Message-ID: <5640c7e00704132207t3ba31229k8e9e11f34613df16@mail.gmail.com>
References: <Pine.LNX.4.64.0704051944230.6730@woody.linux-foundation.org>
	 <20070414003625.GS5907@stusta.de>
	 <Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@stusta.de>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, "Ingo Molnar" <mingo@elte.hu>,
	"Ayaz Abdulla" <aabdulla@nvidia.com>,
	"Dave Jones" <davej@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, "Greg KH" <greg@kroah.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:10132 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbXDNFH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 01:07:56 -0400
Received: by py-out-1112.google.com with SMTP id a29so817575pyi
        for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 22:07:55 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0704131821020.28042@woody.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/14/07, Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
> Note: Ingo also reports what looks like a memory corruption due to
> the 6b6b6b6b pattern on presumably the same box.
>
> The 6b6b6b6b pattern is POISON_FREE, implying some kind of slab misuse,
> most likely a use-after-free, although possibly just due to overrunning a
> slab into the next one or something like that.
>
> What I'm leading up to is that I'm wondering if these mysterious network
> driver bugs aren't due to the network drivers themselves, but due to some
> higher-level problem. I think the hangs that Ingo sees with forcedeth were
> preceded by mysterious and "impossible" NULL pointer oopses. Ingo?
>
> Davem - have there been network infrastructure changes that migt be
> suspect? Jeff and/or Greg - anything in the generic network driver/device
> driver level? We had some trouble earlier with the transition to the
> driver core, and kref miscounting. Related? The last Oops Ingo saw was a
> module refcounting one, iirc.
>
> It does seem networking related somehow. Yeah, it could be obviously be a
> combination of independent bugs both in e1000/ and forcedeth drivers, but
> maybe there is something in common here...
>
I don't know if this is a red herring or not but I reported on March
13th slab corruption and it looked like file_free_rcu - these are
fairly recent changes I think (rcu)?

Anyway original message is at http://lkml.org/lkml/2007/3/12/364

My apologies if this is not related.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
