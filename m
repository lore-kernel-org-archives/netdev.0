From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Fri, 20 Mar 2015 15:51:11 -0700
Message-ID: <CACcJQnQvY1ZgXktqNizzf0vm3WuDMc1==FSRt1no39QofgrB3Q@mail.gmail.com>
References: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
	<20150320.162819.1225364903839854931.davem@davemloft.net>
	<CACcJQnRnjuMXqp38qFmX1-ehSoP6aDC4Wk=Mn9e7681CQB=cqg@mail.gmail.com>
	<20150320.181536.662222674547158857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:33216 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbbCTWvM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 18:51:12 -0400
Received: by yhpt93 with SMTP id t93so46352220yhp.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 15:51:11 -0700 (PDT)
In-Reply-To: <20150320.181536.662222674547158857.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 3:15 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Date: Fri, 20 Mar 2015 14:16:26 -0700
>
>> What we are looking for is a way for user space to hold the device
>> down on detecting incorrect config/topology and for enabling the
>> device once the error condition is removed provided the administrato=
r
>> didn=E2=80=99t intentionally disable it. And we don't see a way for =
a user
>> protocol to do this without involving the kernel.
>
> It is not your business to override what the administrator asks for.
>
> This is what I mean by "cooperative".
>
> ip link up has no idea about your error states, neither does every
> administrator out there.
>
> So you're changing behavior in an incompatible way.
>
> This is why you need a wholistic approach in userland that propagates
> this knowledge all around, rather than just using a sledge hammer by
> asking the kernel to enforce some new rule upon unsuspecting existing
> users.

I agree with you, applications cannot/must not override the
administrator=E2=80=99s directive. I also agree that =E2=80=9Cip link s=
et up=E2=80=9D doesn=E2=80=99t
need to know about errors that user daemons detect.

That is one of the reasons for not clearing IFF_UP from the user space
MLAG application on detecting errors. But I need a way to notify the
device drivers (of the devices that have MLAG enabled) that an error
has occurred allowing them to handle the error gracefully i.e. without
traffic getting black holed.

The change in the net core is only to prevent the oper state from
going UP when errors are encountered not to dev_close (Sorry, I think
I caused this confusion by saying error =E2=80=9Cdisable=E2=80=9D). Thi=
s in some way
is similar to the dormant mode/state implementation which lets the
user space application/driver influence the operstate. Only additional
thing here is a notification that let=E2=80=99s drivers know that error=
s have
been encountered on the device.
