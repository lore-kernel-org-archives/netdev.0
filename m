From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Sat, 17 Aug 2013 10:53:00 -0700
Message-ID: <CAPshTCgpE3MoR3D8=EZa_CFVDBwN+fYDZZQrTchhtq-OM_rKzQ@mail.gmail.com>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
	<1363625464-21633-2-git-send-email-dmitry@broadcom.com>
	<1363651672.21184.17.camel@edumazet-glaptop>
	<504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f169.google.com ([209.85.128.169]:36935 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754107Ab3HQRxB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 13:53:01 -0400
Received: by mail-ve0-f169.google.com with SMTP id db10so2186670veb.0
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 10:53:00 -0700 (PDT)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20BE935B@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry,

On Mon, Mar 18, 2013 at 11:30 PM, Dmitry Kravkov <dmitry@broadcom.com> =
wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.=
org] On Behalf Of Eric Dumazet
>> Sent: Tuesday, March 19, 2013 2:08 AM
>> To: Dmitry Kravkov
>> Cc: davem@davemloft.net; netdev@vger.kernel.org; Eilon Greenstein; T=
om Herbert; Maciej =AFenczykowski
>> Subject: Re: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE =
traffic
>>
>> On Mon, 2013-03-18 at 18:51 +0200, Dmitry Kravkov wrote:
>> > The patch drives FW to perform RSS for GRE traffic,
>> > based on inner headers.
>> >
>> > Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>> > ---
>> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 +++
>> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c  |   23 ++++++++++=
++-----------
>> >  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h  |    9 +++++++++
>> >  3 files changed, 24 insertions(+), 11 deletions(-)
>>
>> This works very well.
>>
>> Problem is we skb_set_queue_mapping(skb, 0); in __skb_tunnel_rx()
>>
>> (this was a patch from Tom Herbert, commit
>> 693019e90ca45d881109d32c0c6d29adf03f6447 (net: reset skb queue mappi=
ng
>> when rx'ing over tunnel )
>>
>> Meaning we hit a single cpu for the GRO stuff in ip_gre.
>>
>> I have to think about it.
>>
>>
>> Another question is :
>>
>> Can bnx2x check the tcp checksum if GRE encapsulated ?
>>
> Current HW can't provide this. Probably, it's possible to separate CS=
UM from GRO/TPA then stack will have to handle CSUM validation for huge=
 packets. Is it worth?

Could you elaborate on what you meant above? (I'm looking for any form
of h/w assist for
csum validation for GRO/TPA pkts since csum computation can be expensiv=
e and  as
you said below CHECKSUM_COMPLETE is out of the question.)

Thanks,

Jerry

>
