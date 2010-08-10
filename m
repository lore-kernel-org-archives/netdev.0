From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: rx_submit() should return an error code.
Date: Tue, 10 Aug 2010 01:41:21 -0700 (PDT)
Message-ID: <20100810.014121.232753083.davem@davemloft.net>
References: <AANLkTimubaXzLjROeaNB0dV09thKfpLDyaEA-t_yzyV1@mail.gmail.com>
	<20100810.001855.179947437.davem@davemloft.net>
	<201008100942.05887.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ellyjones@google.com, stern@rowland.harvard.edu,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	jglasgow@google.com
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36880
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752872Ab0HJIlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:41:01 -0400
In-Reply-To: <201008100942.05887.oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Tue, 10 Aug 2010 09:42:05 +0200

> Am Dienstag, 10. August 2010, 09:18:55 schrieb David Miller:
>> From: Elly Jones <ellyjones@google.com>
>> Date: Mon, 9 Aug 2010 18:37:50 -0400
>> 
>> > This patch makes rx_submit() return an error code, and makes some call sites
>> > that care check the return value. This is important because it lets us properly
>> > handle cases where the device isn't ready to handle URB submissions (e.g., when
>> > it is autosuspended under some drivers); previously, we would attempt and fail
>> > to submit URBs and reschedule ourselves to try and fail again. This patch is
>> > against Linus's 2.6 repo commit 45d7f32c7a43cbb9592886d38190e379e2eb2226.
>> > 
>> > Signed-Off-By: Elizabeth Jones <ellyjones@google.com>
>> 
>> What gets kevent() running again to run the rx_submit() calls when the
>> device comes back from being suspended?
>> 
> 
> usbnet_resume() schedules usbnet_bh() which will take care of that.

That makes sense, I've applied Elizabeth's patch.

But Elizabeth, your patch was severely corrupted by your email client.
Long lines were split up into two, etc.  This corrupts the patch and
makes it unusable for us.  Please make sure that you have fixed your
email client setup for the next patch you submit.

Thanks.
