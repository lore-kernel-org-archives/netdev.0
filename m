From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/2] isdn/gigaset: reset tty->receive_room when attaching
 ser_gigaset
Date: Tue, 14 Jul 2015 01:58:24 +0200
Message-ID: <55A450A0.4080806@imap.cc>
References: <cover.1436826434.git.tilman@imap.cc> <ff18ec15ffc6347cd5574a66eb67cc9483361afa.1436826434.git.tilman@imap.cc> <55A44662.4080706@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>, linux-kernel@vger.kernel.org
To: Peter Hurley <peter@hurleysoftware.com>,
	Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55A44662.4080706@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 14.07.2015 um 01:14 schrieb Peter Hurley:
> On 07/13/2015 06:37 PM, Tilman Schmidt wrote:
>> Commit 79901317ce80 ("n_tty: Don't flush buffer when closing ldisc"),
>> first merged in kernel release 3.10, caused the following regression
>> in the Gigaset M101 driver:
>>
>> Before that commit, when closing the N_TTY line discipline in
>> preparation to switching to N_GIGASET_M101, receive_room would be
>> reset to a non-zero value by the call to n_tty_flush_buffer() in
>> n_tty's close method. With the removal of that call, receive_room
>> might be left at zero, blocking data reception on the serial line.
> 
> That commit didn't cause the problem; it was a bug all along.

Sure. That's why it is correctly fixed in the Gigaset driver.
But before that commit the bug was never actually triggered.
So that commit defines the point in the commit history from
which the fix is needed, and therefore needs to be mentioned
in order to decide which stable releases will need the fix.

> Non-flow controlling line disciplines _must_ set tty->receive_room
> on line discipline open because they are declaring that every
> input they can accept that much data.

I have submitted a corresponding fix to the line discipline
documentation separately.

Thanks,
Tilman
