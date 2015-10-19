From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Mon, 19 Oct 2015 11:06:49 +0200
Message-ID: <20151019110649.726f1fe0@griffin>
References: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
	<20151018151157.GA19163@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas Haller <thaller@redhat.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34783 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbbJSJGx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 05:06:53 -0400
In-Reply-To: <20151018151157.GA19163@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Oct 2015 08:11:58 -0700, Alexei Starovoitov wrote:
> it looks dangerous.
> Does it mean that 'for (4B) { create new dev; free old dev; }
> will keep incrementing that max index and dos it eventually?

This is not changed by this patch in any way. As for the current
behavior (with or without my patch), by creating and deleting an
interface, the max index indeed keeps incrementing. There's no DoS,
however, as the index simply wraps to 1 when reaching maxint. See
dev_new_index(). This is something I count on in this patch.

 Jiri

-- 
Jiri Benc
