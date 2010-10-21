From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 09/14] bnx2: Update bnx2 to use new vlan accleration.
Date: Thu, 21 Oct 2010 14:38:34 -0700
Message-ID: <AANLkTikaE-88LSZcMhZaqrpJzeZi0gSdQX1KAvj5vOPA@mail.gmail.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
	<1287618974-4714-10-git-send-email-jesse@nicira.com>
	<1287675106.2235.10.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57946 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758450Ab0JUVif convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:38:35 -0400
Received: by wyf28 with SMTP id 28so81761wyf.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:38:34 -0700 (PDT)
In-Reply-To: <1287675106.2235.10.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 8:31 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2010-10-20 at 16:56 -0700, Jesse Gross wrote:
>> Make the bnx2 driver use the new vlan accleration model.
>>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> CC: Michael Chan <mchan@broadcom.com>
>> ---
>> =A0drivers/net/bnx2.c | =A0 97 +++++++++++++++----------------------=
---------------
>> =A0drivers/net/bnx2.h | =A0 =A04 --
>> =A02 files changed, 28 insertions(+), 73 deletions(-)
>>
>> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
>> index 363ca8b..bf3c830 100644
>> --- a/drivers/net/bnx2.c
>> +++ b/drivers/net/bnx2.c
> [...]
>> @@ -7578,7 +7523,28 @@ bnx2_set_tx_csum(struct net_device *dev, u32 =
data)
>> =A0static int
>> =A0bnx2_set_flags(struct net_device *dev, u32 data)
>> =A0{
>> - =A0 =A0 return ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH);
>> + =A0 =A0 struct bnx2 *bp =3D netdev_priv(dev);
>> + =A0 =A0 int rc;
>> +
>> + =A0 =A0 if (!(bp->flags & BNX2_FLAG_CAN_KEEP_VLAN) &&
>> + =A0 =A0 =A0 =A0 !(data & ETH_FLAG_RXVLAN))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
> [...]
>
> Should be -EINVAL.

OK, thanks.  I've sent out a patch to fix this (and a similar one in
the bnx2x driver).
