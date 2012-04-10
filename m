From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 05/10] net: move destructor_arg to the front of sk_buff.
Date: Tue, 10 Apr 2012 20:41:05 +0200
Message-ID: <1334083265.5300.288.camel@edumazet-glaptop>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
	 <1334067984-7706-5-git-send-email-ian.campbell@citrix.com>
	 <4F847CF9.3090701@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46948 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357Ab2DJSlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 14:41:12 -0400
Received: by bkcik5 with SMTP id ik5so79796bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 11:41:11 -0700 (PDT)
In-Reply-To: <4F847CF9.3090701@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 11:33 -0700, Alexander Duyck wrote:

> Have you checked this for 32 bit as well as 64?  Based on my math your
> next patch will still mess up the memset on 32 bit with the structure
> being split somewhere just in front of hwtstamps.
> 
> Why not just take frags and move it to the start of the structure?  It
> is already an unknown value because it can be either 16 or 17 depending
> on the value of PAGE_SIZE, and since you are making changes to frags the
> changes wouldn't impact the alignment of the other values later on since
> you are aligning the end of the structure.  That way you would be
> guaranteed that all of the fields that will be memset would be in the
> last 64 bytes.
> 

Now when a fragmented packet is copied in pskb_expand_head(), you access
two separate zones of memory to copy the shinfo. But its supposed to be
slow path.

Problem with this is that the offsets of often used fields will be big
(instead of being < 127) and code will be bigger on x86.
