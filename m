From: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>
Subject: Re: pull request: wireless 2012-02-20
Date: Tue, 21 Feb 2012 22:38:16 +0200
Message-ID: <CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
References: <20120220203740.GD6740@tuxdriver.com>
	<20120220.192324.498901675497866305.davem@davemloft.net>
	<20120221151435.GA19354@tuxdriver.com>
	<20120221.144417.1445117001833888214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:55950 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753424Ab2BUUiS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 15:38:18 -0500
In-Reply-To: <20120221.144417.1445117001833888214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Feb 21, 2012 at 9:44 PM, David Miller <davem@davemloft.net> wro=
te:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Tue, 21 Feb 2012 10:14:36 -0500
>
>> On Mon, Feb 20, 2012 at 07:23:24PM -0500, David Miller wrote:
>>> From: "John W. Linville" <linville@tuxdriver.com>
>>> Date: Mon, 20 Feb 2012 15:37:40 -0500
>>>
>>> > Here is another batch of fixes intended for 3.3. =A0Most of the f=
ixes
>>> > this time are for Bluetooth.
>>>
>>> Pulled, but please read the bluetooth changes more carefully in the
>>> future, there were a lot of coding style errors introduced this
>>> time around.
>>
>> I pinged Johan about this, and he tells me that he spoke to Marcel
>> as well. =A0They were a bit unsure about the issue. =A0Is your conce=
rn
>> primarily about some excessive tabbing for indentation of parameters
>> and such?
>
> So you actually looked at the changes you pushed to me and you are
> telling me you personally can't find anything that looks like garbage=
?
>
> Really? =A0Do I really have to point out such obvious stuff like this=
?
> Are you serious?
>
> Look at ca0d6c7ece0e78268cd7c5c378d6b1b610625085 ("Bluetooth: Add
> missing QUIRK_NO_RESET test to hci_dev_do_close")
>
> You tell me what the heck you think of this thing.
>
> - =A0 =A0 =A0 if (!test_bit(HCI_RAW, &hdev->flags)) {
> + =A0 =A0 =A0 if (!test_bit(HCI_RAW, &hdev->flags) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 test_bi=
t(HCI_QUIRK_NO_RESET, &hdev->quirks)) {
>
> That's disgusting, it jumps off the screen and says "Hello, I am ugly
> as sin". =A0How in the world can you miss something like this? =A0Fou=
r
> TABs on the second line? =A0Why? =A0I can't believe we even have to d=
iscuss
> something like this, seriously.

Sorry did we understand wrong text of Linux coding style? Or do we need
right interpretation of it?

http://www.kernel.org/doc/Documentation/CodingStyle

Statements longer than 80 columns will be broken into sensible chunks.
Descendants are always substantially shorter than the parent and are pl=
aced
substantially to the right. The same applies to function headers with a=
 long
argument list. Long strings are as well broken into shorter strings. Th=
e
only exception to this is where exceeding 80 columns significantly incr=
eases
readability and does not hide information.

void fun(int a, int b, int c)
{
	if (condition)
		printk(KERN_WARNING "Warning this is a long printk with "
						"3 parameters a: %u b: %u "
						"c: %u \n", a, b, c);
	else
		next_statement;
}

>
> Commit 6e1da683f79a22fafaada62d547138daaa9e3456 ("Bluetooth: l2cap_se=
t_timer
> needs jiffies as timeout value"):
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_chan_timer(chan, L2CAP_DISC_REJ_T=
IMEOUT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_chan_timer(chan,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 msecs_t=
o_jiffies(L2CAP_DISC_REJ_TIMEOUT));
>
> You can't see that mis-tabbed thing on the second new line? =A0Really=
?

Are those lines longer then 80 characters?
Otherwise same applies here.

Regards,
Andrei
