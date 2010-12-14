From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH net-2.6] net: fix nulls list corruptions in sk_prot_alloc
Date: Tue, 14 Dec 2010 18:30:47 +0200
Message-ID: <201012141830.47958.opurdila@ixiacom.com>
References: <1292341443-18360-1-git-send-email-opurdila@ixiacom.com> <1292343557.5934.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Leonard Crestez <lcrestez@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:8709 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757107Ab0LNQat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 11:30:49 -0500
In-Reply-To: <1292343557.5934.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tuesday 14 December 2010, 18:19:17

> Hmm very good catch, but why a so invasive patch ?
> 
> Only udp needs a special care.
> 
> Other protocols could use the default 'cleaner', you dont need to force
> them to use the default ;)
> 

Ah, OK now I get it. I thought that for protocols using non nulls lists we 
must clear .next but I now see that we can skip that.

So default cleaner can be the nulls cleaner and portaddr cleaner will be used 
for UDP and UDP lite. I'll rework the patch and post a new version.

