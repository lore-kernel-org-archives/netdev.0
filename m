From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next] sctp: no need to check asoc_id before calling sctp_assoc_set_id
Date: Wed, 24 May 2017 02:25:01 +0800
Message-ID: <CADvbK_cQZuin4duGayoJ1ecfyLmm+yS_FZ5e7QpB47bkbnY8-A@mail.gmail.com>
References: <8ccb4ee656bcdfa790e4f3ee919bb300e4adc4cc.1495521032.git.lucien.xin@gmail.com>
 <20170523180425.GH4642@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        davem <davem@davemloft.net>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:33546 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965624AbdEWSZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 14:25:02 -0400
In-Reply-To: <20170523180425.GH4642@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 24, 2017 at 2:04 AM, Marcelo Ricardo Leitner
<marcelo.leitner@gmail.com> wrote:
[...]
>
> On Tue, May 23, 2017 at 02:30:32PM +0800, Xin Long wrote:
>> sctp_assoc_set_id has already done the asoc_id check in the beginning
>                   s/^^^^^^^^^^^^^^^^/does/
> Very important to use the right tense here as otherwise it gives the
> impression that the check was already made, which is not true.
Sure, will change it and post v2.
But may be later than another two patches in my hands.

>
>> when processing dupcook, no need to do the same check before calling
>                 s/^^^^^^^/dupcookie/
Oh, can't believe it's still here ;)
will correct it. thanks.

>
> other than this, LGTM, including the comment update.
>
>   Marcelo
>
>> it.
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/sctp/associola.c | 8 ++------
>>  1 file changed, 2 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
>> index a9708da..ce2a3ec 100644
>> --- a/net/sctp/associola.c
>> +++ b/net/sctp/associola.c
>> @@ -1181,12 +1181,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
>>                       new->stream = NULL;
>>               }
>>
>> -             if (!asoc->assoc_id) {
>> -                     /* get a new association id since we don't have one
>> -                      * yet.
>> -                      */
>> -                     sctp_assoc_set_id(asoc, GFP_ATOMIC);
>> -             }
>> +             /* get a new association id if we don't have one yet. */
>> +             sctp_assoc_set_id(asoc, GFP_ATOMIC);
>>       }
>>
>>       /* SCTP-AUTH: Save the peer parameters from the new associations
>> --
>> 2.1.0
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
