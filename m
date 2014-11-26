From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/5] ethernet/intel: Use eth_skb_pad helper
Date: Tue, 25 Nov 2014 17:43:05 -0800
Message-ID: <1416966185.29427.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20>
	 <20141125224406.1867.97911.stgit@ahduyck-vm-fedora20>
	 <1416957251.29427.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54752263.2040204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:56245 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaKZBnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 20:43:07 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so1708678iec.8
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 17:43:07 -0800 (PST)
In-Reply-To: <54752263.2040204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-25 at 16:44 -0800, Alexander Duyck wrote:


> 
> I wonder if we couldn't make this some sort of netdevice attribute to
> indicate what the smallest frame we can handle is and then just pad the
> frame to that as a part of __dev_xmit_skb.  Then we could do that
> outside of the locks and take care of it before we even hit the qdisc layer.

Well, many NIC do not have such restriction.

Do we have some kind of counters of skb->head reallocations caused by
this padding ?

I believe I finally have an idea why we had various + 15 in skb
allocations in TCP stack !

We probably should reinstate them, as ACK packets can be 54 bytes long.
