From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Sat, 04 Apr 2009 17:05:39 -0700 (PDT)
Message-ID: <20090404.170539.148727646.davem@davemloft.net>
References: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: amluto@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755867AbZDEAGI@vger.kernel.org>
In-Reply-To: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lutomirski <amluto@gmail.com>
Date: Wed, 1 Apr 2009 11:40:06 -0400

> When a network driver registers a new interface, linkwatch will not notice,
> and hence not set the rfc2863 operstate, until netif_carrier_on gets called.
> If the new interface has no carrier when it is connected, then a status of
> "unknown" is reported to userspace, which confuses various tools
> (NetworkManager, for example).
> 
> This fires a linkwatch event for all new interfaces, so that operstate
> gets set reasonably quickly.
> 
> Signed-off-by: Andrew Lutomirski <amluto@gmail.com>

The default assumed state for a freshly registered network
device is that the link is up.

If that disagrees from reality, the driver should make the
appropriate netif_carrier_off() call.

I'm sure you'll find that the e1000 driver is not doing this
and that is what causes the bug you are seeing.
