From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/9] netdev: bfin_mac: add support
	for IEEE 1588 PTP
Date: Tue, 11 May 2010 23:31:37 -0400
Message-ID: <AANLkTimPOxc4RQ5iDMk8N9xYFb95VaqFleUa_nG4Gwwn@mail.gmail.com>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
	<20100511070716.GA3254@riccoc20.at.omicron.at> <AANLkTikcdpIlZAE-AwahNie8KOys7jIhiNb9kiT_B7Av@mail.gmail.com>
	<AANLkTilpgUrQfFpmgHhUSCprbnTSC9LCGpFxSUEaGSWr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	Barry Song <barry.song@analog.com>,
	"David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org
To: Barry Song <21cnbao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f198.google.com ([209.85.211.198]:52589 "EHLO
	mail-yw0-f198.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab0ELDb6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 23:31:58 -0400
Received: by ywh36 with SMTP id 36so3111897ywh.4
        for <netdev@vger.kernel.org>; Tue, 11 May 2010 20:31:57 -0700 (PDT)
In-Reply-To: <AANLkTilpgUrQfFpmgHhUSCprbnTSC9LCGpFxSUEaGSWr@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 11, 2010 at 23:20, Barry Song wrote:
> On Wed, May 12, 2010 at 5:03 AM, Mike Frysinger wrote:
>> On Tue, May 11, 2010 at 03:07, Richard Cochran wrote:
>>> On Mon, May 10, 2010 at 11:39:06AM -0400, Mike Frysinger wrote:
>>>> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
>>>> index 587f93c..6a9519f 100644
>>>> --- a/drivers/net/bfin_mac.c
>>>> +++ b/drivers/net/bfin_mac.c
>>> ...
>>>> +#define PTP_CLK 25000000
>>>> +
>>>> +static void bfin_mac_hwtstamp_init(struct net_device *netdev)
>>>> +{
>>>> + =C2=A0 =C2=A0 struct bfin_mac_local *lp =3D netdev_priv(netdev);
>>>> + =C2=A0 =C2=A0 u64 append;
>>>> +
>>>> + =C2=A0 =C2=A0 /* Initialize hardware timer */
>>>> + =C2=A0 =C2=A0 append =3D PTP_CLK * (1ULL << 32);
>>>> + =C2=A0 =C2=A0 do_div(append, get_sclk());
>>>> + =C2=A0 =C2=A0 bfin_write_EMAC_PTP_ADDEND((u32)append);
>>>
>>> It appears that one can tune this PTP clock.
>>>
>>> I recently posted a suggestion for a PTP clock class driver. Would =
you
>>> care to take a look at that and say whether that API would also wor=
k
>>> for the blackfin?
>>
>> i'm guessing you mean:
>> http://thread.gmane.org/gmane.linux.network/159179
>> http://thread.gmane.org/gmane.linux.network/159180
>> http://thread.gmane.org/gmane.linux.network/159181
>> http://thread.gmane.org/gmane.linux.network/159182
>>
>> Barry: could you take a look please ?
>
> I think the API can work for blackfin. =C2=A0But our PTP driver is ba=
sed on
> drivers/net/igb and has worked together with user-space PTPD utility.
> Here he is writing a different driver framework. It is not the moment
> for us to merge now. Maybe next kernel version after his patches have
> been popular.

i'm not going to merge them into our tree ahead of the net->mainline
merge.  Richard would just like some feedback on the proposed
framework to make sure it doesnt have limitations we'd have to fix
after things get merged.
-mike
