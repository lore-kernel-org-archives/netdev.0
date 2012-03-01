From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: Resend: [PATCH] Bluetooth: Fix Endian Bug.
Date: Thu, 1 Mar 2012 19:34:58 +0530
Message-ID: <CAOD=uF4LSS8nuKMNHGEH2JsVZHU0rntSxZjvNaa4oZrey1macw@mail.gmail.com>
References: <1330599561-20392-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120301123540.GE25627@aemeltch-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>,
	santosh nayak <santoshprasadnayak@gmail.com>,
	marcel@holtmann.org, padovan@profusion.mobi, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120301123540.GE25627@aemeltch-MOBL1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrei,

I could not get you.

Do you want me to resend the patch with subject,
  "[PATCH] Bluetooth: Fix network to host endian conversion for L2CAP
chan id."  ?



regards
santosh




On Thu, Mar 1, 2012 at 6:05 PM, Andrei Emeltchenko
<andrei.emeltchenko.news@gmail.com> wrote:
> Hi Santosh,
>
> On Thu, Mar 01, 2012 at 04:29:21PM +0530, santosh nayak wrote:
>> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>>
>> Fix for endian bug.
>>
>> Fix for null dereferenced removed as it is already
>> submitted by Andrei.
>>
>> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
>> ---
>> =A0net/bluetooth/l2cap_sock.c | =A0 =A05 +++--
>> =A01 files changed, 3 insertions(+), 2 deletions(-)
>
> We prefer following commit log (this is the example)
>
> <------8<----------------------------------------------------------
> | =A0From: Santosh Nayak <santoshprasadnayak@gmail.com>
> |
> | =A0Fix network to host endian conversion for L2CAP chan id.
> |
> | =A0Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
> |
> | =A0---
> | =A0 =A0 =A0 =A0 =A0* v2 Fix for null dereferenced removed as it is =
already
> | =A0 =A0 =A0 =A0 =A0submitted by Andrei.
> |
> | =A0 =A0net/bluetooth/l2cap_sock.c | =A0 =A05 +++--
> | =A0 =A01 files changed, 3 insertions(+), 2 deletions(-)
> |
> <------8<----------------------------------------------------------
>
>
>>
>> diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
>> index 401d942..86d5067 100644
>> --- a/net/bluetooth/l2cap_sock.c
>> +++ b/net/bluetooth/l2cap_sock.c
>> @@ -82,7 +82,7 @@ static int l2cap_sock_bind(struct socket *sock, st=
ruct sockaddr *addr, int alen)
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 if (la.l2_cid)
>> - =A0 =A0 =A0 =A0 =A0 =A0 err =3D l2cap_add_scid(chan, la.l2_cid);
>> + =A0 =A0 =A0 =A0 =A0 =A0 err =3D l2cap_add_scid(chan, __le16_to_cpu=
(la.l2_cid));
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D l2cap_add_psm(chan, &la.l2_bdadd=
r, la.l2_psm);
>>
>> @@ -123,7 +123,8 @@ static int l2cap_sock_connect(struct socket *soc=
k, struct sockaddr *addr, int al
>> =A0 =A0 =A0 if (la.l2_cid && la.l2_psm)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>>
>> - =A0 =A0 err =3D l2cap_chan_connect(chan, la.l2_psm, la.l2_cid, &la=
=2El2_bdaddr);
>> + =A0 =A0 err =3D l2cap_chan_connect(chan, la.l2_psm, __le16_to_cpu(=
la.l2_cid),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &la.l2_bda=
ddr);
>
> I live this to Marcel to decide should we reindent our code otherwise=
 this
> one looks odd.
>
> Best regards
> Andrei Emeltchenko
>
