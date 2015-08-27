From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH net v4] sctp: asconf's process should verify address
 parameter is in the beginning
Date: Thu, 27 Aug 2015 16:25:18 +0800
Message-ID: <CADvbK_cf9_Y5eaKyA_3sdSHZMd6sc3KHLZ=zYjUxkY7OSR6VLg@mail.gmail.com>
References: <e003fc0660f6b2eefd25618ea7a037e62952a54d.1440623004.git.lucien.xin@gmail.com>
	<55DE30A8.7020402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	davem <davem@davemloft.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:32968 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbbH0IZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 04:25:19 -0400
Received: by oigm66 with SMTP id m66so1746430oig.0
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 01:25:18 -0700 (PDT)
In-Reply-To: <55DE30A8.7020402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 5:33 AM, Vlad Yasevich <vyasevic@redhat.com> wrote:
> On 08/26/2015 05:03 PM, Xin Long wrote:
>> in sctp_process_asconf(), we get address parameter from the beginning of
>> the addip params. but we never check if it's really there. if the addr
>> param is not there, it still can pass sctp_verify_asconf(), then to be
>> handled by sctp_process_asconf(), it will not be safe.
>>
>> so add detection in sctp_verify_asconf() to check the address parameter is in
>> the beginning, or return false to send abort.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>
>
> -vlad
>
>> ---
>>  net/sctp/sm_make_chunk.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>> index 06320c8..f3fc881 100644
>> --- a/net/sctp/sm_make_chunk.c
>> +++ b/net/sctp/sm_make_chunk.c
>> @@ -3132,12 +3132,14 @@ bool sctp_verify_asconf(const struct sctp_association *asoc,
>>               case SCTP_PARAM_IPV4_ADDRESS:
>>                       if (length != sizeof(sctp_ipv4addr_param_t))
>>                               return false;
>> -                     addr_param_seen = true;
>> +                     if (param.v == addip->addip_hdr.params)
>> +                             addr_param_seen = true;
>>                       break;
>>               case SCTP_PARAM_IPV6_ADDRESS:
>>                       if (length != sizeof(sctp_ipv6addr_param_t))
>>                               return false;
>> -                     addr_param_seen = true;
>> +                     if (param.v == addip->addip_hdr.params)
>> +                             addr_param_seen = true;
>>                       break;
>>               case SCTP_PARAM_ADD_IP:
>>               case SCTP_PARAM_DEL_IP:
>>
>

let's forget this one, I will repost.
