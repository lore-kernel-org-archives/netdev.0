From: Shirley Ma <mashirle@us.ibm.com>
Subject: RE: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Tue, 14 Sep 2010 19:40:52 -0700
Message-ID: <1284518452.13351.111.camel@localhost.localdomain>
References: <1284410580.13351.10.camel@localhost.localdomain>
	 <1284410883.13351.14.camel@localhost.localdomain>
	 <20100913.201730.27805132.davem@davemloft.net>
	 <4C8F3C77.7010302@redhat.com>
	 <1284476719.13351.35.camel@localhost.localdomain>
	 <F2E9EB7348B8264F86B6AB8151CE2D792B8C8152A0@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:34427 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244Ab0IOCk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 22:40:58 -0400
In-Reply-To: <F2E9EB7348B8264F86B6AB8151CE2D792B8C8152A0@shsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-15 at 09:50 +0800, Xin, Xiaohui wrote:
> I think what David said is what we have thought before in mp device.
> Since we are not sure the exact time the tx buffer was wrote though
> DMA operation.
> But the deadline is when the tx buffer was freed. So we only notify
> the vhost stuff
> about the write when tx buffer freed. But the deadline is maybe too
> late for performance.

Have you tried it? If so what's the performance penalty you have seen by
notifying vhost when tx buffer freed?

I am thinking to have a callback in skb destructor,
vhost_add_used_and_signal gets updated when skb is actually freed, vhost
vq & head need to be passed to the callback. This might requires vhost
ring size is at least as big as the lower device driver. 

Thanks
Shirley

