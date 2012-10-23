From: Tony Cheneau <tony.cheneau@amnesiak.org>
Subject: Re: [PATCH net-next 06/15] 6lowpan: fix first fragment (FRAG1)  handling
Date: Tue, 23 Oct 2012 16:50:27 +0200
Message-ID: <1bf85bdd4343fe738d15ee74a65578d5@amnesiak.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
 <1350965397-12384-7-git-send-email-tony.cheneau@amnesiak.org>
 <5086450A.9050506@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-zigbee-devel@lists.sourceforge.net>,
	Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.amnesiak.org ([95.130.11.136]:54794 "EHLO amnesiak.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745Ab2JWOvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 10:51:02 -0400
In-Reply-To: <5086450A.9050506@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jan,

Thank you for all your comments. See my answer inline.

Le 23.10.2012 09:19, Jan Ceuleers a =C3=A9crit=C2=A0:
> On 10/23/2012 06:09 AM, Tony Cheneau wrote:
>> The first fragment, FRAG1, must contain some payload according to=20
>> the
>> specs. However, as it is currently written, the first fragment will
>> remain empty and only contain the 6lowpan headers.
>>
>> This patch also extract the transport layer information from the=20
>> first
>> fragment. This information is later on use when uncompressing UDP
>> header.
>>
>> Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
>> ---
>>  net/ieee802154/6lowpan.c |   54=20
>> +++++++++++++++++++++++++++++++++++----------
>>  1 files changed, 42 insertions(+), 12 deletions(-)
>>
>> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>> index 8a2ee95..38cecaf 100644
>> --- a/net/ieee802154/6lowpan.c
>> +++ b/net/ieee802154/6lowpan.c
>> @@ -654,7 +654,7 @@ static void=20
>> lowpan_fragment_timer_expired(unsigned long entry_addr)
>>  }
>>
>>  static struct lowpan_fragment *
>> -lowpan_alloc_new_frame(struct sk_buff *skb, u8 len, u16 tag)
>> +lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
>>  {
>>  	struct lowpan_fragment *frame;
>>
>> @@ -735,6 +735,18 @@ lowpan_process_data(struct sk_buff *skb)
>>  		/* adds the 3 MSB to the 8 LSB to retrieve the 11 bits length */
>>  		len =3D ((iphc0 & 7) << 8) | slen;
>>
>> +		if ((iphc0 & LOWPAN_DISPATCH_MASK) =3D=3D LOWPAN_DISPATCH_FRAG1) =
{
>> +			pr_debug("%s received a FRAG1 packet (tag: %d, "
>> +				 "size of the entire IP packet: %d)"
>> +				 , __func__, tag, len);
>
> There are several schools of thought on the relative importance of
> observing the 80-character line limit versus breaking up string
> constants (in an attempt to maintain grepability). I think the above=20
> is
> fine but others (whose opinion matters more than mine) may or may not
> agree. Whatever you decide here, please apply consistently=20
> throughout.
Yes, I've seen that particular issues when running checkpatch.pl. I=20
decided to break down line, but I can easily be convinced to do things=20
differently. Anyway, I'll make sure that all my patches are consistent=20
in breaking up string after 80 characters the same way.

> However, the comma ahead of the __func__ should be at the end of the
> previous line.
Will do.

>
>> -	/* if payload length is zero, therefore it's a first fragment */
>> -	hlen =3D (plen =3D=3D 0 ? LOWPAN_FRAG1_HEAD_SIZE : =20
>> LOWPAN_FRAGN_HEAD_SIZE);
>> +	hlen =3D (type =3D=3D LOWPAN_DISPATCH_FRAG1 ? LOWPAN_FRAG1_HEAD_SI=
ZE :
>> +			LOWPAN_FRAGN_HEAD_SIZE);
>
> The second line of this statement should be aligned as follows:
>
> +	hlen =3D (type =3D=3D LOWPAN_DISPATCH_FRAG1 ? LOWPAN_FRAG1_HEAD_SIZ=
E :
> +		LOWPAN_FRAGN_HEAD_SIZE);
>
> So the L for LOWPAN_FRAGN_HEAD_SIZE should be underneath the t for=20
> type.
Will do as well.

Again, thank you for all your detailed comments.

Regards,
Tony
