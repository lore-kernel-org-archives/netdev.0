From: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>
Subject: Re: [Unstrung-hackers] [RFC net-next] ipv6:
 =?UTF-8?Q?ext=5Fheader=3A=20add=20function=20to=20handle=20RPL=20extensio?=
 =?UTF-8?Q?n=20header=20option=20=30x=36=33?=
Date: Fri, 05 May 2017 09:55:54 +0200
Message-ID: <96b9f3bc67da7c16249600990c2df4cc@ceid.upatras.gr>
References: <dca567582f1979384fb1f3c3d1411349@ceid.upatras.gr>
 <20170504160042.GB2385@nanopsycho>
 <CAAK7Ti9iFFqM7vMyveNfaNeCi6PmAGptXdTYgEzh2gsMptqi4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        Michael Richardson <mcr@sandelman.ca>,
        netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, linux-wpan@vger.kernel.org,
        unstrung-hackers@lists.sandelman.ca
To: JANARDHANACHARI KELLA <eni.chari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poseidon.ceid.upatras.gr ([150.140.141.169]:57388 "EHLO
        poseidon.ceid.upatras.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753894AbdEEH4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 03:56:10 -0400
In-Reply-To: <CAAK7Ti9iFFqM7vMyveNfaNeCi6PmAGptXdTYgEzh2gsMptqi4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes I think we have faced the same problem,communication with RPL 
supporting devices was failing otherwise.Your patch is also more 
complete since it also implements #ifdef .About the comment,yes I have 
run checkpatch twice with no errors,but ok :)

Στις 2017-05-05 08:59, JANARDHANACHARI KELLA έγραψε:
> I was inserted this patch manually. It was working. on 4.9 kernel.
> 
> check this bellow link for your ref.
> 
> https://github.com/mwasilak/bluetooth-next/commit/f29c632ef6a6a1777815c97fd2f326faccc704f7
> [2]
> 
> On Thu, May 4, 2017 at 9:30 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> 
>> Thu, May 04, 2017 at 05:17:18PM CEST, bardoutsos@ceid.upatras.gr
>> wrote:
>>> Signed-off-by: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>
>>> ---
>>> Hi all!
>>> 
>>> I have added a dump function(always return true) to recognise RPL
>> extension
>>> header(RFC6553)
>>> Otherwise packet was dropped by kernel resulting in failing
>> communication in
>>> RPL DAG's between
>>> linux running border routers and devices in the graph.For example
>>> communication
>>> with contiki OS running devices was previously impossible.
>>> 
>>> include/uapi/linux/in6.h | 1 +
>>> net/ipv6/exthdrs.c | 13 +++++++++++++
>>> 2 files changed, 14 insertions(+)
>>> 
>>> diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
>>> index 46444f8fbee4..5cc12d309dfe 100644
>>> --- a/include/uapi/linux/in6.h
>>> +++ b/include/uapi/linux/in6.h
>>> @@ -146,6 +146,7 @@ struct in6_flowlabel_req {
>>> #define IPV6_TLV_CALIPSO 7 /* RFC 5570 */
>>> #define IPV6_TLV_JUMBO 194
>>> #define IPV6_TLV_HAO 201 /* home address option */
>>> +#define IPV6_TLV_RPL 99 /* RFC 6553 */
>>> 
>>> /*
>>> * IPV6 socket options
>>> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
>>> index b636f1da9aec..82ed60d3180e 100644
>>> --- a/net/ipv6/exthdrs.c
>>> +++ b/net/ipv6/exthdrs.c
>>> @@ -785,6 +785,15 @@ static bool ipv6_hop_calipso(struct sk_buff
>> *skb, int
>>> optoff)
>>> return false;
>>> }
>>> 
>>> +/* RPL RFC 6553 */
>>> +
>>> +static bool ipv6_hop_rpl(struct sk_buff *skb, int optoff)
>>> +{
>>> + /*Dump function which always return true
>>> + *when rpl option is detected*/
>> 
>> This is definitelly wrong formatting of comment. Did you run
>> checkpatch?
>> 
>>> + return true;
>>> +}
>>> +
>>> static const struct tlvtype_proc tlvprochopopt_lst[] = {
>>> {
>>> .type = IPV6_TLV_ROUTERALERT,
>>> @@ -798,6 +807,10 @@ static const struct tlvtype_proc
>> tlvprochopopt_lst[] = {
>>> .type = IPV6_TLV_CALIPSO,
>>> .func = ipv6_hop_calipso,
>>> },
>>> + {
>>> + .type = IPV6_TLV_RPL,
>>> + .func = ipv6_hop_rpl,
>>> + },
>>> { -1, }
>>> };
>>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe
>> linux-wpan" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>> [1]
> 
> --
> 
> Sincerely Your's
> 
> Janardhanachari Kella
> 
> Contact:+91-9908469599
> E-mail: eni.chari@gmail.com
> 
> 
> Links:
> ------
> [1] http://vger.kernel.org/majordomo-info.html
> [2]
> https://github.com/mwasilak/bluetooth-next/commit/f29c632ef6a6a1777815c97fd2f326faccc704f7
> 
> _______________________________________________
> Unstrung-hackers mailing list
> Unstrung-hackers@lists.sandelman.ca
> https://lists.sandelman.ca/mailman/listinfo/unstrung-hackers
