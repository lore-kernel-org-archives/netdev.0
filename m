From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCHv2 RESEND] {xfrm, sctp} Stick to software crc32 even if hardware is capable of that
Date: Mon, 14 Oct 2013 10:16:41 -0400
Message-ID: <fed034cb-be28-488b-883f-627e8e7499b9@email.android.com>
References: <1381735658-15478-1-git-send-email-fan.du@windriver.com> <525BA63A.7040708@redhat.com> <525BAC6A.8000004@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, steffen.klassert@secunet.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:34166 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755820Ab3JODBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 23:01:17 -0400
Received: by mail-qa0-f51.google.com with SMTP id ii20so2916316qab.3
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 20:01:16 -0700 (PDT)
In-Reply-To: <525BAC6A.8000004@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=46an Du <fan.du@windriver.com> wrote:

>
>
>On 2013=E5=B9=B410=E6=9C=8814=E6=97=A5 16:07, Daniel Borkmann wrote:
>> On 10/14/2013 09:27 AM, Fan Du wrote:
>>> igb/ixgbe have hardware sctp checksum support, when this feature is
>enabled
>>> and also IPsec is armed to protect sctp traffic, ugly things
>happened as
>>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum
>every thing
>>> up and pack the 16bits result in the checksum field). The result is
>fail
>>> establishment of sctp communication.
>>>
>>> Signed-off-by: Fan Du <fan.du@windriver.com>
>>> Cc: Vlad Yasevich <vyasevich@gmail.com>
>>> Cc: Neil Horman <nhorman@tuxdriver.com>
>>> Cc: Steffen Klassert <steffen.klassert@secunet.com>
>>> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>>> ---
>>>   net/sctp/output.c |   14 +++++++++++++-
>>>   1 file changed, 13 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/sctp/output.c b/net/sctp/output.c
>>> index 0ac3a65..6de6402 100644
>>> --- a/net/sctp/output.c
>>> +++ b/net/sctp/output.c
>>> @@ -372,6 +372,16 @@ static void sctp_packet_set_owner_w(struct
>sk_buff *skb, struct sock *sk)
>>>       atomic_inc(&sk->sk_wmem_alloc);
>>>   }
>>>
>>> +static int is_xfrm_armed(struct dst_entry *dst)
>>> +{
>>> +#ifdef CONFIG_XFRM
>>> +    /* If dst->xfrm is valid, this skb needs to be transformed */
>>> +    return dst->xfrm !=3D NULL;
>>> +#else
>>> +    return 0;
>>> +#endif
>>> +}
>>
>> Instead of putting this into SCTP code, isn't the above rather a
>candidate for
>> include/net/xfrm.h, e.g. as ... bool xfrm_is_armed(...) ?
>
>Should be in such style in terms of its name, but this is truly SCTP
>specific in this scenario.
>No one elsewhere barely need this as far as I can tell...

It almost begs for dst_xfrm() function that returns NULL or dst->xfrm.
Thar can live in dst code.

-vlad

--=20
Sent from my Android phone with K-9 Mail. Please excuse my brevity.
