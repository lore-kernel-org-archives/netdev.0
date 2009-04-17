From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3]
Date: Fri, 17 Apr 2009 01:23:16 -0700 (PDT)
Message-ID: <20090417.012316.209396377.davem@davemloft.net>
References: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmitry.krivoschekov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754291AbZDQIXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 04:23:25 -0400
In-Reply-To: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dmitry.krivoschekov@gmail.com
Date: Thu, 16 Apr 2009 13:37:36 +0400

> this patch series adds some flexibility to ip_auto_config() function.
> Currently the function assumes that 500 msec delay before opening
> a network device is enough, but it's not true for some h/w configurations,
> e.g. if you're using a USB network device. 
> In my case it may take up to 2 seconds before the device gets available 
> for opening.

I think this problem space would be served better by a scheme
that just worked automatically.

If the user put nfsroot= onto the kernel command line, the expectation
is that the device is expected to be there.

Therefore it is reasonable to make the ipconfig.c code do a loop
periodically retrying to open the intended network device.  And after
several seconds of iterations, fail.

Heck, it doesn't even need to do anything fancy.  After the initial
attempt, it can simply wait for the NETDEV_REGISTER notifier event.
Then it will know exactly when the device shows up.

In fact you won't need anything to implement this, simply register the
notifier and make the notifier trigger the ipconfig.c code to do a
DHCP or RARP probe or whatever when the device we're interested in
appears.

I'm not applying these patches, sorry.
