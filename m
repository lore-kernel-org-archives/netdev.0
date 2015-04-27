From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bluetooth: Skip the shutdown routine if the interface
 is not up
Date: Mon, 27 Apr 2015 01:01:14 -0400 (EDT)
Message-ID: <20150427.010114.1023073688671559343.davem@davemloft.net>
References: <1430074310-3192-1-git-send-email-gabriele.mzt@gmail.com>
	<C0DF74E2-3705-42A4-898D-3E89C8C95D4A@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gabriele.mzt@gmail.com, tedd.an@intel.com, gustavo@padovan.org,
	johan.hedberg@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: marcel@holtmann.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C0DF74E2-3705-42A4-898D-3E89C8C95D4A@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sun, 26 Apr 2015 21:49:06 -0700

> Hi Gabriele,
> 
>> Most likely, the shutdown routine requires the interface to be up.
>> This is the case for BTUSB_INTEL: the routine tries to send a command
>> to the interface, but since this one is down, it fails and exits once
>> HCI_INIT_TIMEOUT has expired.
>> 
>> Signed-off-by: Gabriele Mazzotta <gabriele.mzt@gmail.com>
>> ---
>> net/bluetooth/hci_core.c | 3 ++-
>> 1 file changed, 2 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
>> index 476709b..4663c3d 100644
>> --- a/net/bluetooth/hci_core.c
>> +++ b/net/bluetooth/hci_core.c
>> @@ -1557,7 +1557,8 @@ static int hci_dev_do_close(struct hci_dev *hdev)
>> {
>> 	BT_DBG("%s %p", hdev->name, hdev);
>> 
>> -	if (!hci_dev_test_flag(hdev, HCI_UNREGISTER)) {
>> +	if (!hci_dev_test_flag(hdev, HCI_UNREGISTER) &&
>> +	    test_bit(HCI_UP, &hdev->flags)) {
>> 		/* Execute vendor specific shutdown routine */
>> 		if (hdev->shutdown)
>> 			hdev->shutdown(hdev);
> 
> this is a good catch.
> 
> Acked-by: Marcel Holtmann <marcel@holtmann.org>
> Cc: stable@vger.kernel.org # 4.0.x
> 
> Dave, do you want to take this patch straight into your stable tree?

Please handle this via the bluetooth tree, thanks.
