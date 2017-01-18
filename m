From: Elad Nachman <EladN@gilat.com>
Subject: RE: Kernel 4.6.7-rt14 kernel workqueue lockup - rtnl deadlock plus
 syscall endless loop
Date: Wed, 18 Jan 2017 09:57:08 +0000
Message-ID: <AM5PR0701MB18732AA38AAB6E39A92FA6E3A07F0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
References: <AM5PR0701MB187338B2418A19E1B4B55C98A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
        <20170117.125748.122599514616047216.davem@davemloft.net>
        <AM5PR0701MB1873F82D61AF17A09F2B0E26A07C0@AM5PR0701MB1873.eurprd07.prod.outlook.com>
 <20170117.140552.539738967862859087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0045.outbound.protection.outlook.com ([104.47.2.45]:59406
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751256AbdARJ5K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 04:57:10 -0500
In-Reply-To: <20170117.140552.539738967862859087.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, how about reflecting the state of the rtnl lock to user space via the /=
proc file system?

This way I can test it before using sysctl on the relevant proc files to av=
oid live-lock.

Thanks,

Elad.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: =E9=E5=ED =E2 17 =E9=F0=E5=E0=F8 2017 21:06
To: Elad Nachman <EladN@gilat.com>
Cc: netdev@vger.kernel.org
Subject: Re: Kernel 4.6.7-rt14 kernel workqueue lockup - rtnl deadlock plus=
 syscall endless loop

From: Elad Nachman <EladN@gilat.com>
Date: Tue, 17 Jan 2017 18:15:19 +0000

> Any thought about limiting the amount of busy polling?  Say if more
> than X polls are done within a jiffy, then at least for preemptable
> kernels you can sleep for a jiffy inside the syscall to yield the
> CPU for a while?

We cannot yield there, because we must return immediately from this
context in order to drop the sysctl locks and references.
IMPORTANT - This email and any attachments is intended for the above named =
addressee(s), and may contain information which is confidential or privileg=
ed. If you are not the intended recipient, please inform the sender immedia=
tely and delete this email: you should not copy or use this e-mail for any =
purpose nor disclose its contents to any person.
