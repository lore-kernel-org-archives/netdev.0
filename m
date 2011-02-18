From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 15:14:56 +0100
Message-ID: <20110218141456.GD2939@psychotron.redhat.com>
References: <20110218132524.GC2939@psychotron.redhat.com>
 <1298035791.6201.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955Ab1BROQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Feb 2011 09:16:59 -0500
Content-Disposition: inline
In-Reply-To: <1298035791.6201.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, Feb 18, 2011 at 02:29:51PM CET, eric.dumazet@gmail.com wrote:
>Le vendredi 18 f=E9vrier 2011 =E0 14:25 +0100, Jiri Pirko a =E9crit :
>> This patch converts bonding to use rx_handler. Results in cleaner
>> __netif_receive_skb() with much less exceptions needed. Also bond-sp=
ecific
>> work is moved into bond code.
>>=20
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>> ---
>>  drivers/net/bonding/bond_main.c |   75 ++++++++++++++++++++-
>>  include/linux/skbuff.h          |    2 +
>>  net/core/dev.c                  |  144 +++++++++++-----------------=
----------
>>  net/core/skbuff.c               |    1 +
>>  4 files changed, 119 insertions(+), 103 deletions(-)
>>=20
>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 31f02d0..9f3af5d 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -267,6 +267,7 @@ typedef unsigned char *sk_buff_data_t;
>>   *	@sk: Socket we are owned by
>>   *	@tstamp: Time we arrived
>>   *	@dev: Device we arrived on/are leaving by
>> + *	@input_dev: Original device on which we arrived
>>   *	@transport_header: Transport layer header
>>   *	@network_header: Network layer header
>>   *	@mac_header: Link layer header
>> @@ -325,6 +326,7 @@ struct sk_buff {
>> =20
>>  	struct sock		*sk;
>>  	struct net_device	*dev;
>> +	struct net_device	*input_dev;
>> =20
>
>Your patch looks fine, but adding 8 bytes to sk_buff for a "cleanup" i=
s
>really a show stopper for me.

Do not know how to do it better. As for percpu variable, not only
origdev would have to be remembered but also probably skb pointer to
know if it's the first run on the skb or not. Can't really figure out a
better solution. Can you?

Thanks.

Jirka
>
>
>
