From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 reset_task question
Date: Wed, 04 Apr 2007 14:37:01 -0700
Message-ID: <1175722621.7911.63.camel@dell>
References: <d66d623f0704041334m5e0c68ebw777f621c779e1153@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Gagan Arneja" <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2768 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751255AbXDDUwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 16:52:18 -0400
In-Reply-To: <d66d623f0704041334m5e0c68ebw777f621c779e1153@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-04 at 13:34 -0700, Gagan Arneja wrote:
> Can't this BUG_ON be hit very easily:
> 
> static void tg3_irq_quiesce(struct tg3 *tp)
> {
>         BUG_ON(tp->irq_sync);
> ...
> }
> 
> tg3_reset_task could easily be racing with another thread, that calls
> tg3_full_lock(tp, 1); e.g tg3_change_mtu. Maybe I'm missing something
> obvious.
> 

Yes, you're right.  Perhaps we should get the rtnl first before
tg3_full_lock(), or turn irq_sync into an atomic counter that allows
nesting.

