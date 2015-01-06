From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] unlock rtnl mutex in ic_open_devs while waiting
Date: Tue, 06 Jan 2015 17:21:52 -0500 (EST)
Message-ID: <20150106.172152.2034122593693302134.davem@davemloft.net>
References: <54AA9706.5020202@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: maarten.lankhorst@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54AA9706.5020202@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maarten Lankhorst <maarten.lankhorst@canonical.com>
Date: Mon, 05 Jan 2015 14:52:06 +0100

> This fixes a deadlock with alx_link_check, which takes the rtnl_mutex in
> a work item to check the link.
> 
> I have no idea whether alx should be fixed or ipconfig.c,
> but this saves 120 seconds off my boot time. ;-)
> 
> Signed-off-by: Maarten Lankhorst <maarten.lankhorst@canonical.com>

I genuinely think that alx_link_check() needs to use a smaller hammer
to do it's locking, there is no reason to use the RTNL mutex.

A driver private mutex will probably work just as well and not have
this problem.
