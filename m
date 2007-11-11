From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3][UNIX] The unix_nr_socks limit can be exceeded
Date: Sat, 10 Nov 2007 22:08:43 -0800 (PST)
Message-ID: <20071110.220843.08991154.davem@davemloft.net>
References: <4731C52D.7020902@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58077
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752549AbXKKGIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 01:08:44 -0500
In-Reply-To: <4731C52D.7020902@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 07 Nov 2007 17:01:17 +0300

> The unix_nr_socks value is limited with the 2 * get_max_files() value,
> as seen from the unix_create1(). However, the check and the actual
> increment are separated with the GFP_KERNEL allocation, so this limit
> can be exceeded under a memory pressure - task may go to sleep freeing
> the pages and some other task will be allowed to allocate a new sock
> and so on and so forth.
> 
> So make the increment before the check (similar thing is done in the
> sock_kmalloc) and go to kmalloc after this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, good catch Pavel.
