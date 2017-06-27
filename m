From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RESEND PATCH v4 1/3] Bluetooth: bnep: fix possible might sleep
 error in bnep_session
Date: Tue, 27 Jun 2017 19:32:52 +0200
Message-ID: <0815411E-62D7-42DC-A0BF-78FD150C0949@holtmann.org>
References: <1498556084-25346-1-git-send-email-jeffy.chen@rock-chips.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        rvaswani@nvidia.com, Brian Norris <briannorris@chromium.org>,
        dmitry.torokhov@gmail.com,
        Douglas Anderson <dianders@chromium.org>, acho@suse.com,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Gustavo F. Padovan" <gustavo@padovan.org>
To: Jeffy Chen <jeffy.chen@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:57763 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751576AbdF0Rcy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 13:32:54 -0400
In-Reply-To: <1498556084-25346-1-git-send-email-jeffy.chen@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeffy,

> It looks like bnep_session has same pattern as the issue reported in
> old rfcomm:
> 
> 	while (1) {
> 		set_current_state(TASK_INTERRUPTIBLE);
> 		if (condition)
> 			break;
> 		// may call might_sleep here
> 		schedule();
> 	}
> 	__set_current_state(TASK_RUNNING);
> 
> Which fixed at:
> 	dfb2fae Bluetooth: Fix nested sleeps
> 
> So let's fix it at the same way, also follow the suggestion of:
> https://lwn.net/Articles/628628/
> 
> Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
> Reviewed-by: Brian Norris <briannorris@chromium.org>
> Reviewed-by: AL Yu-Chen Cho <acho@suse.com>
> ---
> 
> Changes in v4: None
> Changes in v2: None
> 
> net/bluetooth/bnep/core.c | 11 +++++------
> 1 file changed, 5 insertions(+), 6 deletions(-)

all 3 patches have been applied to bluetooth-next tree.

Regards

Marcel
