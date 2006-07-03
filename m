From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/7] net_device list cleanup: core
Date: Mon, 3 Jul 2006 18:46:50 +0100
Message-ID: <20060703174650.GA22295@infradead.org>
References: <20060630150823.A22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:4750 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751224AbWGCRrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 13:47:01 -0400
To: Andrey Savochkin <saw@swsoft.com>
Content-Disposition: inline
In-Reply-To: <20060630150823.A22285@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 03, 2006 at 12:18:51PM +0400, Andrey Savochkin wrote:
> Cleanup of net_device list use in net_dev core and IP.
> The cleanup consists of
>  - converting the to list_head, to make the list double-linked (thus making
>    remove operation O(1)), and list walks more readable;
>  - introducing of for_each_netdev wrapper over list_for_each.

When you change all this please make sure dev_base_head is never directly
accessed anymore, not even through macros and dev_base_head is not exported
anymore.  That's the only way to keep drivers messing with it.

Yes, it's a little more work as you need to audit all drivers to see what
they are doing and find suitable abstractions but it's a must have that
should have been done a lot earlier.

