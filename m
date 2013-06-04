From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [BUG] acess_ok() missing from zerocopy_sg_from_iovec()
Date: Tue, 4 Jun 2013 08:30:04 +0300
Message-ID: <20130604053004.GA19433@redhat.com>
References: <1370306052.24311.193.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498Ab3FDF3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 01:29:33 -0400
Content-Disposition: inline
In-Reply-To: <1370306052.24311.193.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 03, 2013 at 05:34:12PM -0700, Eric Dumazet wrote:
> It looks like access_ok(VERIFY_READ, base, len) checks are missing in
> drivers/net/tun.c & drivers/net/macvtap.c before the
> get_user_pages_fast() calls.
> 
> Or am I missing something ?

These paths (zero-copy xmit) are only used through vhost-net which does
its own access_ok checks.

Needs a comment, I agree.
