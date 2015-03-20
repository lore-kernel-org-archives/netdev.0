From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/3] net: introduce IFF_PROTO_DOWN flag.
Date: Fri, 20 Mar 2015 09:13:56 -0700
Message-ID: <CAADnVQKyOA7QADk9KOz_-ZFO+WJs2bbRsXZyXXr0sWag4jpOBw@mail.gmail.com>
References: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:32940 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbCTQOS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 12:14:18 -0400
Received: by qgfa8 with SMTP id a8so96976671qgf.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 09:14:17 -0700 (PDT)
In-Reply-To: <1426864318-25132-1-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 8:11 AM,  <anuradhak@cumulusnetworks.com> wrote=
:
> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>
> Applications can detect errors in the network that would require
> disabling the device independent of the admin state. In the presence =
of
> these errors traffic could be black holed or looped resulting in a
> network meltdown. Clearing the IFF_UP flag for error disabling the
> device can be problematic because -
>
> 1. The administrator cannot distinguish between a user space daemon=E2=
=80=99s
> error-disable and a regular device disable.
> 2. Applications can monitor the error state and enable the device onc=
e
> the error is removed. If IFF_UP is used for this purpose the applicat=
ion
> may end up enabling a device that the administrator has intentionally
> disabled for other reasons. This could result in network changes not
> expected by the admin.
>

Both reasons look like workaround for user space issues.
Just keep this fake-down state in userspace.
What's the point pushing it to kernel?
looking at 3rd patch:
+ * @IF_LINK_PROTO_DOWN_MLAG: proto_down by a multi-chassis LAG applica=
tion.
+ * @IF_LINK_PROTO_DOWN_STP: proto_down by an STP application.

so there will be new flag for every application that cannot deal with
normal down?
