From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: Distributed storage.
Date: Fri, 3 Aug 2007 00:09:02 -0400
Message-ID: <170fa0d20708022109s60ebb85aqe68ec1033634ef27@mail.gmail.com>
References: <20070731171347.GA14267@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Daniel Phillips" <phillips@phunq.net>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:51235 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbXHCEJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 00:09:05 -0400
Received: by py-out-1112.google.com with SMTP id d32so1223254pye
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2007 21:09:02 -0700 (PDT)
In-Reply-To: <20070731171347.GA14267@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/31/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Hi.
>
> I'm pleased to announce first release of the distributed storage
> subsystem, which allows to form a storage on top of remote and local
> nodes, which in turn can be exported to another storage as a node to
> form tree-like storages.

Very interesting work, I read through your blog for the project and it
is amazing how quickly you developed/tested this code.  Thanks for
capturing the evolution of DST like you have.

> Compared to other similar approaches namely iSCSI and NBD,
> there are following advantages:
>     * non-blocking processing without busy loops (compared to both above)
>     * small, plugable architecture
>     * failover recovery (reconnect to remote target)
>     * autoconfiguration (full absence in NBD and/or device mapper on top of it)
>     * no additional allocatins (not including network part) - at least two in
>         device mapper for fast path
>     * very simple - try to compare with iSCSI
>     * works with different network protocols
>     * storage can be formed on top of remote nodes and be exported
>         simultaneously (iSCSI is peer-to-peer only, NBD requires device
>         mapper and is synchronous)

Having the in-kernel export is a great improvement over NBD's
userspace nbd-server (extra copy, etc).

But NBD's synchronous nature is actually an asset when coupled with MD
raid1 as it provides guarantees that the data has _really_ been
mirrored remotely.

> TODO list currently includes following main items:
>     * redundancy algorithm (drop me a request of your own, but it is highly
>         unlikley that Reed-Solomon based will ever be used - it is too slow
>         for distributed RAID, I consider WEAVER codes)

I'd like to better understand where you see DST heading in the area of
redundancy.    Based on your blog entries:
http://tservice.net.ru/~s0mbre/blog/devel/dst/2007_07_24_1.html
http://tservice.net.ru/~s0mbre/blog/devel/dst/2007_07_31_2.html
(and your todo above) implementing a mirroring algorithm appears to be
a near-term goal for you.  Can you comment on how your intended
implementation would compare, in terms of correctness and efficiency,
to say MD (raid1) + NBD?  MD raid1 has a write intent bitmap that is
useful to speed resyncs; what if any mechanisms do you see DST
embracing to provide similar and/or better reconstruction
infrastructure?  Do you intend to embrace any exisiting MD or DM
infrastructure?

BTW, you have definitely published some very compelling work and its
sad that you're predisposed to think DST won't be recieved well if you
pushed for inclusion (for others, as much was said in the 7.31.2007
blog post I referenced above).  Clearly others need to embrace DST to
help inclusion become a reality.  To that end, its great to see that
Daniel Phillips and the other zumastor folks will be putting DST
through its paces.

regards,
Mike
