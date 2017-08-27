From: Greg KH <greg@kroah.com>
Subject: Re: Stable apply request [was: Bluetooth: bnep: fix possible might
 sleep error in bnep_session]
Date: Sun, 27 Aug 2017 15:10:14 +0200
Message-ID: <20170827131014.GA10491@kroah.com>
References: <1498556084-25346-1-git-send-email-jeffy.chen@rock-chips.com>
 <0815411E-62D7-42DC-A0BF-78FD150C0949@holtmann.org>
 <373da46b-41f7-9aa2-946d-75633c9efe86@suse.cz>
 <E0E7758A-9E4C-4179-8403-D8895424586B@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby@suse.cz>,
        Jeffy Chen <jeffy.chen@rock-chips.com>,
        stable <stable@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        rvaswani@nvidia.com, Brian Norris <briannorris@chromium.org>,
        dmitry.torokhov@gmail.com,
        Douglas Anderson <dianders@chromium.org>, acho@suse.com,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Gustavo F. Padovan" <gustavo@padovan.org>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E0E7758A-9E4C-4179-8403-D8895424586B@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2017 at 08:14:15PM +0200, Marcel Holtmann wrote:
> Hi Jiri,
> 
> >>> It looks like bnep_session has same pattern as the issue reported in
> >>> old rfcomm:
> >>> 
> >>> 	while (1) {
> >>> 		set_current_state(TASK_INTERRUPTIBLE);
> >>> 		if (condition)
> >>> 			break;
> >>> 		// may call might_sleep here
> >>> 		schedule();
> >>> 	}
> >>> 	__set_current_state(TASK_RUNNING);
> >>> 
> >>> Which fixed at:
> >>> 	dfb2fae Bluetooth: Fix nested sleeps
> >>> 
> >>> So let's fix it at the same way, also follow the suggestion of:
> >>> https://lwn.net/Articles/628628/
> > 
> > ...
> > 
> >> all 3 patches have been applied to bluetooth-next tree.
> > 
> > Hi,
> > 
> > given users are hitting it in at least 4.4 and 4.12, can we have all
> > three in all stables where this applies?
> > 
> > 5da8e47d849d Bluetooth: hidp: fix possible might sleep error in
> > hidp_session_thread
> > f06d977309d0 Bluetooth: cmtp: fix possible might sleep error in cmtp_session
> > 25717382c1dd Bluetooth: bnep: fix possible might sleep error in bnep_session
> > 
> > I am not sure: to stable directly or via net stable?
> 
> as Dave said, just email -stable directly and have Greg pick them up.

All now picked up :)
