From: Bruce Cole <bacole@gmail.com>
Subject: Re: e1000 driver and samba
Date: Thu, 20 Sep 2007 16:30:48 -0700
Message-ID: <46F302A8.7040008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bacole@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:16691 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053AbXITXeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 19:34:00 -0400
Received: by wa-out-1112.google.com with SMTP id v27so780957wah
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 16:33:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>If you look for it on the Realtek cards, there had been sporadic
>Nissues up to late 2005. The solution posted universally was 'change
>card'.

Yes, that *was* the common recommendation.  But recently I narrowed down the
realtek performance problem most commonly seen with samba (but also applicable
to other TCP applications), and I also narrowed down the fix as well.

The current fix involves re-kicking the TX queue after it becomes stuck.
Apparently it becomes stuck due to a contention problem between the driver and
controller.  I suspect the root problem is the driver isn't properly locking
the TX queue.  It might be worth checking if the queue locking problem exists
in other net drivers as well. 

Reference:
http://www.spinics.net/lists/netdev/msg40384.html


