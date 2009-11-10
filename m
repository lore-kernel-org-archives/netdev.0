From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Wed, 11 Nov 2009 00:40:48 +0300
Message-ID: <20091110214048.GA20517@ioremap.net>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com> <20091110143652.GB19645@redhat.com> <4AF98A8C.9040201@novell.com> <20091110173644.GA8888@redhat.com> <4AF9B2A7.3050802@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:39767 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758241AbZKJVkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 16:40:43 -0500
Content-Disposition: inline
In-Reply-To: <4AF9B2A7.3050802@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 01:36:23PM -0500, Gregory Haskins (ghaskins@novell.com) wrote:
> What about things like sendfile()?  There has to be *some* way to
> synchronize with the io-completion event,  I would think.  Whatever that
> is, I'd like to tap into it.

All skb manipulation functions properly maintain data reference
counters, so pages will not be freed until all data is consumed.
But there is no guarantee that data placed in given page will not be
overwritten while page is being held somewhere in the stack.

Putting shared info destructor will allow to get notification, that
given shared info processing is over, i.e. that network stack does not
use data placed in shared info for given skb, but if it was copied or
VFS hold those pages, they may or may not be freed.

-- 
	Evgeniy Polyakov
