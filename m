From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Fri, 20 Mar 2015 14:16:26 -0700
Message-ID: <CACcJQnRnjuMXqp38qFmX1-ehSoP6aDC4Wk=Mn9e7681CQB=cqg@mail.gmail.com>
References: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
	<20150320.162819.1225364903839854931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f54.google.com ([209.85.213.54]:36608 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbbCTVQ1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:16:27 -0400
Received: by yhjf44 with SMTP id f44so45521933yhj.3
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:16:27 -0700 (PDT)
In-Reply-To: <20150320.162819.1225364903839854931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 1:28 PM, David Miller <davem@davemloft.net> wro=
te:
> From: anuradhak@cumulusnetworks.com
> Date: Fri, 20 Mar 2015 08:11:55 -0700
>
>> Applications can detect errors in the network that would require
>> disabling the device independent of the admin state.
>
> I hate changes like this.
>
> The only reason it exists, is because you don't want to put together
> the infrastructure and framework necessary for applications managing
> this state in userspace to _work_ _together_.  So you make it a kerne=
l
> problem.
>
> UP/DOWN is a boolean state, that's not changing.
>
> So you need to design your stuff such that one entity takes all of th=
e
> collective decisions together and calculates the final up/down state,
> and then asks the kernel to do that.
>
> Nothing is more bullshit than having someone ask the kernel to up the
> interface and the thing doesn't come up because of this auxiliary
> crap.  That's broken and nobody is going to expect nor be happy with
> that behavior.

I understand your position on this. And I agree .... ..however, in
this particular case ....

Unfortunately there is no way to distinguish between admin state and
error state in the user space. Currently administrators are directly
using =E2=80=9Cip link set up/down=E2=80=9D/IFF_UP as a means to admin-=
enable/disable
a device. So even if we were to consolidate all the errors in the user
space there is no way to error-disable/enable a device without
overriding the administrator=E2=80=99s directive.

What we are looking for is a way for user space to hold the device
down on detecting incorrect config/topology and for enabling the
device once the error condition is removed provided the administrator
didn=E2=80=99t intentionally disable it. And we don't see a way for a u=
ser
protocol to do this without involving the kernel.

Thanks for the review.
