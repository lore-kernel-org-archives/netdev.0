From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 RESEND] {xfrm, sctp} Stick to software crc32 even if
 hardware is capable of that
Date: Mon, 14 Oct 2013 16:33:46 +0800
Message-ID: <525BAC6A.8000004@windriver.com>
References: <1381735658-15478-1-git-send-email-fan.du@windriver.com> <525BA63A.7040708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62828 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874Ab3JNIfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 04:35:30 -0400
In-Reply-To: <525BA63A.7040708@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8814=E6=97=A5 16:07, Daniel Borkmann wrote:
> On 10/14/2013 09:27 AM, Fan Du wrote:
>> igb/ixgbe have hardware sctp checksum support, when this feature is =
enabled
>> and also IPsec is armed to protect sctp traffic, ugly things happene=
d as
>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum ev=
ery thing
>> up and pack the 16bits result in the checksum field). The result is =
fail
>> establishment of sctp communication.
>>
>> Signed-off-by: Fan Du <fan.du@windriver.com>
>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Cc: Steffen Klassert <steffen.klassert@secunet.com>
>> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>> ---
>>   net/sctp/output.c |   14 +++++++++++++-
>>   1 file changed, 13 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sctp/output.c b/net/sctp/output.c
>> index 0ac3a65..6de6402 100644
>> --- a/net/sctp/output.c
>> +++ b/net/sctp/output.c
>> @@ -372,6 +372,16 @@ static void sctp_packet_set_owner_w(struct sk_b=
uff *skb, struct sock *sk)
>>       atomic_inc(&sk->sk_wmem_alloc);
>>   }
>>
>> +static int is_xfrm_armed(struct dst_entry *dst)
>> +{
>> +#ifdef CONFIG_XFRM
>> +    /* If dst->xfrm is valid, this skb needs to be transformed */
>> +    return dst->xfrm !=3D NULL;
>> +#else
>> +    return 0;
>> +#endif
>> +}
>
> Instead of putting this into SCTP code, isn't the above rather a cand=
idate for
> include/net/xfrm.h, e.g. as ... bool xfrm_is_armed(...) ?

Should be in such style in terms of its name, but this is truly SCTP sp=
ecific in this scenario.
No one elsewhere barely need this as far as I can tell...

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
