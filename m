From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v7 03/33] net: set name_assign_type in alloc_netdev()
Date: Thu, 10 Jul 2014 12:21:44 +0200
Message-ID: <CAG-2HqVvW2dh5y8xn9v-B29ohFTcPGgY3NY-P5y_xZu0SGgG3g@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-4-git-send-email-teg@jklm.no> <87tx6ph8u5.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87tx6ph8u5.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 10, 2014 at 11:16 AM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
> Tom Gundersen <teg@jklm.no> writes:
>
>> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
>> index 5dc638c..f405e05 100644
>> --- a/net/ethernet/eth.c
>> +++ b/net/ethernet/eth.c
>> @@ -390,7 +390,8 @@ EXPORT_SYMBOL(ether_setup);
>>  struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int=
 txqs,
>>                                     unsigned int rxqs)
>>  {
>> -     return alloc_netdev_mqs(sizeof_priv, "eth%d", ether_setup, txq=
s, rxqs);
>> +     return alloc_netdev_mqs(sizeof_priv, "eth%d", NET_NAME_UNKNOWN=
,
>> +                             ether_setup, txqs, rxqs);
>>  }
>>  EXPORT_SYMBOL(alloc_etherdev_mqs);
>
> I believe this chunk makes the rest of this exercise pretty pointless=
=2E
>
> bjorn@nemi:/usr/local/src/git/linux$ git grep alloc_etherdev drivers/=
net/|wc -l
> 283
>
> I don't care enough to go look, but I'd be surprised if none of those
> drivers rename the device before registering it.

I did look for that, and I only found devices being renamed to the
same name assign type as eth%d (wlan%d, etc).

Cheers,

Tom
