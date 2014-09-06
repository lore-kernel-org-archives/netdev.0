From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] bluetooth: btusb: Fix issue with suspend
Date: Sat, 6 Sep 2014 10:35:50 -0700
Message-ID: <D5B40282-A085-4B47-8F7B-27480CAB6B19@holtmann.org>
References: <1409930194-6318-1-git-send-email-Larry.Finger@lwfinger.net> <6DF81E54-681F-4B18-95C7-F4684FF19786@holtmann.org> <540B4159.9000003@lwfinger.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	BlueZ development <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Champion Chen <champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <540B4159.9000003-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Larry,

>>> Suspend could fail for some platforms because
>>> btusb_suspend==> btusb_stop_traffic ==> usb_kill_anchored_urbs,
>>> 
>>> When btusb_bulk_complete returns before system suspend and resubmits an urb,
>>> the system cannot enter suspend state.
>>> 
>>> Signed-off-by: Champion Chen <champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
>>> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
>>> Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
>>> ---
>>> Johan,
>>> 
>>> To help Champion with the process, I have formatted the patch in
>>> the correct manner. I hope I understand the issue correctly and
>>> stated it in a coherent manner in the commit message.
>>> 
>>> Larry
>>> ---
>>> drivers/bluetooth/btusb.c | 9 +++++++++
>>> 1 file changed, 9 insertions(+)
>>> 
>>> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
>>> index 292c38e..45a7211 100644
>>> --- a/drivers/bluetooth/btusb.c
>>> +++ b/drivers/bluetooth/btusb.c
>>> @@ -330,6 +330,9 @@ static void btusb_intr_complete(struct urb *urb)
>>> 			BT_ERR("%s corrupted event packet", hdev->name);
>>> 			hdev->stat.err_rx++;
>>> 		}
>>> +	} else if (urb->status == -ENOENT) {
>>> +		/* Avoid suspend failed when usb_kill_urb */
>>> +		return;
>>> 	}
>>> 
>>> 	if (!test_bit(BTUSB_INTR_RUNNING, &data->flags))
>>> @@ -417,6 +420,9 @@ static void btusb_bulk_complete(struct urb *urb)
>>> 						urb->actual_length) < 0) {
>>> 			BT_ERR("%s corrupted ACL packet", hdev->name);
>>> 			hdev->stat.err_rx++;
>>> +		} else if (urb->status == -ENOENT) {
>>> +			/* Avoid suspend failed when usb_kill_urb */
>>> +			return;
>>> 		}
>> 
>> this one is utterly bogus. Either urb->status is 0 or it is -ENOENT, but it will not be both. I think you put it to the wrong if clause.
> 
> Thanks for the review. Obviously, you are correct. A revised patch will be sent soon.

one other thing. Please let maintainers decide when a patch is useful for stable and when not. Patches need to go upstream first anyway. People spamming stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org with patches that are not reviewed yet is pretty much a waste of time.

Regards

Marcel
