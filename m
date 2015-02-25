From: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Subject: Re: [PATCH] proc: proc_create() should return true if CONFIG_PROC_FS
 is not configured
Date: Wed, 25 Feb 2015 02:48:30 -0500
Message-ID: <CAPFHKzcLsL9Sb_ma4_XCm4a0kX_iNcCdFVXf346wtnmOPqWcEg@mail.gmail.com>
References: <1424841259-8470-1-git-send-email-zhangzl2013@126.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	viro@zeniv.linux.org.uk, dhowells@redhat.com
To: Zhang Zhaolong <zhangzl2013@126.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:39420 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbBYHtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 02:49:01 -0500
Received: by wggx12 with SMTP id x12so1855654wgg.6
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 23:49:00 -0800 (PST)
In-Reply-To: <1424841259-8470-1-git-send-email-zhangzl2013@126.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 12:14 AM, Zhang Zhaolong <zhangzl2013@126.com> wrote:
>
> proc_create() should return true if CONFIG_PROC_FS is not configured.
> Otherwise if-statement like this "if (!proc_create())" would go to the false path.

Does that even compile? proc_create() and proc_create_data() both return
"struct proc_dir_entry *". It doesn't make sense for those macros to "return"
anything but NULL - certainly not 1.

Besides, why shouldn't "if (!proc_create())" behave like proc_create()
failed when
CONFIG_PROC_FS is not enabled?  You wouldn't want the caller to start trying
to use that ((struct proc_dir_entry *)1) would you?
