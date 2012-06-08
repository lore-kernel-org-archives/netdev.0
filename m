From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Fri, 8 Jun 2012 23:24:08 +0800
Message-ID: <CA+v9cxag9NV2ud+oupyziLN3nLgkgj+kyTcaOnEjYNjqXtM4Bw@mail.gmail.com>
References: <CA+v9cxbogzS7sVChqkRMgDUcs=aJgNDRH8ydoQ-_htfS2t52gQ@mail.gmail.com>
	<Pine.LNX.4.44L0.1206080940350.1360-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36745 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204Ab2FHPYJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 11:24:09 -0400
In-Reply-To: <Pine.LNX.4.44L0.1206080940350.1360-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 8, 2012 at 9:43 PM, Alan Stern <stern@rowland.harvard.edu> =
wrote:
> On Fri, 8 Jun 2012, Huajun Li wrote:
>
>> > If so, looks mistaken value is returned from the host controller d=
river,
>> > but not sure if your device is buggy. What is your host controller=
?
>> >
>> Nothing related to HC.
>> I tried to find out the endpoint state, but found it was halt. I thi=
nk
>> this is the root cause.
>
> No, it isn't. =A0Endpoint halt causes a -EPIPE error, not -EPROTO.
> -EPROTO indicates that the device's firmware has crashed.
>
>> What's your opinion to handle "-EPROTO" error in usbnet.c?
>> Please check usbnet.c again, when "-EPROTO" occurs, it just pints
>> error msg and re-submit the interrupt URB, and then causes endless
>> "EactErr" error msg.
>
> One possibility is to wait for a little while before resubmitting the
> URB, and after 10 failures in a row, attempt a reset.
>
Alan, thanks for your proposal.
You mean reset the device after 10 failures, right ?

BTW, I ever tried to sleep several seconds before submitting the 1st
interrupt URB, but it did not work.
