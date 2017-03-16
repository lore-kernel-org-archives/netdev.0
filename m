From: Kevin Xu <kaiwen.xu@hulu.com>
Subject: Re: [PATCH] [PATCH net] net: Do not hold the reference for the same
 sk_rx_dst.
Date: Thu, 16 Mar 2017 10:12:55 +0000
Message-ID: <242C9F89-8639-4C31-B3E5-B56C4F785E41@hulu.com>
References: <1489651711-4105-1-git-send-email-kaiwen.xu@hulu.com>,<87h92tv8uv.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jakub Sitnicki <jkbs@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0120.outbound.protection.outlook.com ([104.47.40.120]:28448
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751141AbdCPKM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Mar 2017 06:12:57 -0400
In-Reply-To: <87h92tv8uv.fsf@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do you mean the message looping endlessly?

If so, then I suppose it's a different bug.

Kevin

> On Mar 16, 2017, at 3:01 AM, Jakub Sitnicki <jkbs@redhat.com> wrote:
>=20
>> On Thu, Mar 16, 2017 at 08:08 AM GMT, Kevin Xu wrote:
>> In some rare cases, inet_sk_rx_dst_set() may be called multiple times
>> on the same dst, causing reference count leakage. Eventually, it
>> prevents net_device to be destroyed. The bug then manifested as
>>=20
>> unregister_netdevice: waiting for lo to become free. Usage count =3D 1
>>=20
>> in the kernel log, preventing new network namespace creation.
>>=20
>> The patch works around the issue by checking whether the socket already
>> has the same dst set.
>>=20
>> Signed-off-by: Kevin Xu <kaiwen.xu@hulu.com>
>> ---
>=20
> FWIW, with this patch applied I'm still sometimes seeing:
>=20
> [  125.928095] unregister_netdevice: waiting for lo to become free. Usage=
 count =3D 1
>=20
> -Jakub
