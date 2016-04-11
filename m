From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Lsf] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Mon, 11 Apr 2016 14:27:40 -0700
Message-ID: <1460410060.6473.574.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com>
	 <1460042309.6473.414.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160409111132.781a11b6@redhat.com>
	 <1460205278.6473.486.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160411222309.499a2125@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lsf@lists.linux-foundation.org, Tom Herbert <tom@herbertland.com>,
	Brenden Blanco <bblanco@plumgrid.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lsf-pc@lists.linux-foundation.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34429 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753672AbcDKV1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 17:27:43 -0400
Received: by mail-pa0-f47.google.com with SMTP id ot11so45257262pab.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 14:27:42 -0700 (PDT)
In-Reply-To: <20160411222309.499a2125@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-04-11 at 22:23 +0200, Jesper Dangaard Brouer wrote:

> If we have a page-pool recycle facility, then we could use the trick,
> right? (As we know that get_page_unless_zero() cannot happen for pages
> in the pool).

Well, if you disable everything that possibly use
get_page_unless_zero(), I guess this could work.

But then, you'll have to spy lkml traffic forever to make sure no new
feature is added in the kernel, using this get_page_unless_zero() in a
new clever way.

You could use a page flag so that z BUG() triggers if
get_page_unless_zero() is attempted on one of your precious pages ;)\

We had very subtle issues before my fixes (check
35b7a1915aa33da812074744647db0d9262a555c and children), so I would not
waste time on the lock prefix avoidance at this point.
