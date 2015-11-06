From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Aw: Re: question about checksumming and tcp_sendpage
Date: Fri, 06 Nov 2015 11:32:56 -0800
Message-ID: <1446838376.4184.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <trinity-80ad84c3-456a-4f51-a3e9-afee4e8ae504-1446759288452@3capp-1and1-bs03>
	, <CALx6S369t4iOKYnM=Qzc-oguVZECK93=VJXbhzt+objjs70W4Q@mail.gmail.com>
	 <trinity-afda3924-c5a6-4998-98b5-ee047f5cbe74-1446837255645@3capp-1and1-bs04>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org
To: ronny.hegewald@online.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35127 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032164AbbKFTc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 14:32:59 -0500
Received: by pasz6 with SMTP id z6so135715844pas.2
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 11:32:58 -0800 (PST)
In-Reply-To: <trinity-afda3924-c5a6-4998-98b5-ee047f5cbe74-1446837255645@3capp-1and1-bs04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-11-06 at 20:14 +0100, ronny.hegewald@online.de wrote:

> I think the checksum-building is not broken because of this on itself. The
> problem i see is for example in case pages are sent from a block-device 
> over the net. 
> 
> Depending on the block-device this pages might be changed at any time. 
> Because of the described issue the page-data wouldn't be copied as a call 
> to sock_no_sendpage would do it. So the page-data might change at any time
> during or after the checksum-building. From my understanding this would just
> cause a crc-error anytime after sending and would only lead to a resent 
> of the data, probably with a new checksum which will then be correct So
> there wouldn't be a obvious impact except some bad tcp packages.

We handle the case just fine.

grep for SKBTX_SHARED_FRAG

(successor of
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=cef401de7be8c4e155c6746bfccf721a4fa5fab
)
