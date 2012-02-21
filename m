From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-02-20
Date: Tue, 21 Feb 2012 14:44:17 -0500 (EST)
Message-ID: <20120221.144417.1445117001833888214.davem@davemloft.net>
References: <20120220203740.GD6740@tuxdriver.com>
	<20120220.192324.498901675497866305.davem@davemloft.net>
	<20120221151435.GA19354@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab2BUTp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 14:45:26 -0500
In-Reply-To: <20120221151435.GA19354@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 21 Feb 2012 10:14:36 -0500

> On Mon, Feb 20, 2012 at 07:23:24PM -0500, David Miller wrote:
>> From: "John W. Linville" <linville@tuxdriver.com>
>> Date: Mon, 20 Feb 2012 15:37:40 -0500
>> 
>> > Here is another batch of fixes intended for 3.3.  Most of the fixes
>> > this time are for Bluetooth.
>> 
>> Pulled, but please read the bluetooth changes more carefully in the
>> future, there were a lot of coding style errors introduced this
>> time around.
> 
> I pinged Johan about this, and he tells me that he spoke to Marcel
> as well.  They were a bit unsure about the issue.  Is your concern
> primarily about some excessive tabbing for indentation of parameters
> and such?

So you actually looked at the changes you pushed to me and you are
telling me you personally can't find anything that looks like garbage?

Really?  Do I really have to point out such obvious stuff like this?
Are you serious?

Look at ca0d6c7ece0e78268cd7c5c378d6b1b610625085 ("Bluetooth: Add
missing QUIRK_NO_RESET test to hci_dev_do_close")

You tell me what the heck you think of this thing.

-	if (!test_bit(HCI_RAW, &hdev->flags)) {
+	if (!test_bit(HCI_RAW, &hdev->flags) &&
+				test_bit(HCI_QUIRK_NO_RESET, &hdev->quirks)) {

That's disgusting, it jumps off the screen and says "Hello, I am ugly
as sin".  How in the world can you miss something like this?  Four
TABs on the second line?  Why?  I can't believe we even have to discuss
something like this, seriously.

Commit 6e1da683f79a22fafaada62d547138daaa9e3456 ("Bluetooth: l2cap_set_timer
needs jiffies as timeout value"):

-		__set_chan_timer(chan, L2CAP_DISC_REJ_TIMEOUT);
+		__set_chan_timer(chan,
+				msecs_to_jiffies(L2CAP_DISC_REJ_TIMEOUT));

You can't see that mis-tabbed thing on the second new line?  Really?

The list goes on and on, just walk through the bluetooth commits from
the other day, stuff like this is all over the place.
