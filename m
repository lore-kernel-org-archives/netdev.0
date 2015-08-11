From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH net] sctp: ASCONF-ACK with Unresolvable Address should
 be sent
Date: Tue, 11 Aug 2015 08:40:34 -0300
Message-ID: <55C9DF32.5060808@gmail.com>
References: <1437800888-17413-1-git-send-email-lucien.xin@gmail.com>
 <20150727134426.GS1730@localhost.localdomain>
 <CADvbK_cgaKf5nAGu-uE9NzgWpXrdHdqO82rAEWd63V9fO88M5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>
To: lucien xin <lucien.xin@gmail.com>, davem <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:33578 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934028AbbHKLko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 07:40:44 -0400
Received: by qged69 with SMTP id d69so136764538qge.0
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 04:40:43 -0700 (PDT)
In-Reply-To: <CADvbK_cgaKf5nAGu-uE9NzgWpXrdHdqO82rAEWd63V9fO88M5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em 11-08-2015 01:34, lucien xin escreveu:
> On Mon, Jul 27, 2015 at 9:44 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
>> On Sat, Jul 25, 2015 at 01:08:08PM +0800, Xin Long wrote:
>>> RFC 5061:
>>>      This is an opaque integer assigned by the sender to identify each
>>>      request parameter.  The receiver of the ASCONF Chunk will copy this
>>>      32-bit value into the ASCONF Response Correlation ID field of the
>>>      ASCONF-ACK response parameter.  The sender of the ASCONF can use this
>>>      same value in the ASCONF-ACK to find which request the response is
>>>      for.  Note that the receiver MUST NOT change this 32-bit value.
>>>
>>>      Address Parameter: TLV
>>>
>>>      This field contains an IPv4 or IPv6 address parameter, as described
>>>      in Section 3.3.2.1 of [RFC4960].
>>>
>>> ASCONF chunk with Error Cause Indication Parameter (Unresolvable Address)
>>> should be sent if the Delete IP Address is not part of the association.
>>>
>>>    Endpoint A                           Endpoint B
>>>    (ESTABLISHED)                        (ESTABLISHED)
>>>
>>>    ASCONF        ----------------->
>>>    (Delete IP Address)
>>>                  <-----------------      ASCONF-ACK
>>>                                          (Unresolvable Address)
>>>
>>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>>> ---
>>>   net/sctp/sm_make_chunk.c | 15 +++++++++++++--
>>>   1 file changed, 13 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>>> index 06320c8..6e399f6 100644
>>> --- a/net/sctp/sm_make_chunk.c
>>> +++ b/net/sctp/sm_make_chunk.c
>>> @@ -3090,8 +3090,19 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
>>>                        sctp_assoc_set_primary(asoc, asconf->transport);
>>>                        sctp_assoc_del_nonprimary_peers(asoc,
>>>                                                        asconf->transport);
>>> -             } else
>>> -                     sctp_assoc_del_peer(asoc, &addr);
>>> +                     return SCTP_ERROR_NO_ERROR;
>>> +             }
>>> +
>>> +             /* If the address is not part of the association, the
>>> +              * ASCONF-ACK with Error Cause Indication Parameter
>>> +              * which including cause of Unresolvable Address should
>>> +              * be sent.
>>> +              */
>>> +             peer = sctp_assoc_lookup_paddr(asoc, &addr);
>>> +             if (!peer)
>>> +                     return SCTP_ERROR_DNS_FAILED;
>>> +
>>> +             sctp_assoc_rm_peer(asoc, peer);
>>>                break;
>>>        case SCTP_PARAM_SET_PRIMARY:
>>>                /* ADDIP Section 4.2.4
>>> --
>>> 2.1.0
>>>
>>
>> Looks good to me.
>>
>>    Marcelo
>>
>
> any update for this one? is it accepted?

You posted it as RFC only. Now we are waiting for its official version.

   Marcelo
