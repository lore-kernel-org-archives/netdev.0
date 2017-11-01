From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH] bpf: remove SK_REDIRECT from UAPI
Date: Wed, 1 Nov 2017 06:50:29 -0700
Message-ID: <c76037b1-cc56-5f1f-5893-2b00d4c895f7@gmail.com>
References: <20171101021731.10955.49498.stgit@john-Precision-Tower-5810>
 <20171101082621.GC1977@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:53313 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754493AbdKANup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 09:50:45 -0400
Received: by mail-pg0-f65.google.com with SMTP id s2so2159794pge.10
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 06:50:45 -0700 (PDT)
In-Reply-To: <20171101082621.GC1977@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2017 01:26 AM, Jiri Pirko wrote:
> Wed, Nov 01, 2017 at 03:17:31AM CET, john.fastabend@gmail.com wrote:
>> Now that SK_REDIRECT is no longer a valid return code. Remove it
>>from the UAPI completely. Then do a namespace remapping internal
>> to sockmap so SK_REDIRECT is no longer externally visible.
>>
>> Patchs primary change is to do a namechange from SK_REDIRECT to
>> __SK_REDIRECT
>>
>> Reported-by: Alexei Starovoitov <ast@kernel.org>
>> Signed-off-by: John Fastabend <john.fastabend@gmail.com>
>> ---
>> include/uapi/linux/bpf.h       |    1 -
>> kernel/bpf/sockmap.c           |   16 ++++++++++++----
>> tools/include/uapi/linux/bpf.h |    3 +--
>> 3 files changed, 13 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>> index 0d7948c..7bf4c75 100644
>> --- a/include/uapi/linux/bpf.h
>> +++ b/include/uapi/linux/bpf.h
>> @@ -788,7 +788,6 @@ struct xdp_md {
>> enum sk_action {
>> 	SK_DROP = 0,
>> 	SK_PASS,
>> -	SK_REDIRECT,
> 
> Is it really ok to do uapi changes like this?
> 

sockmap feature was only added in net so there is no released kernel
with SK_REDIRECT. And there is no user facing code that can interpret
the SK_REDIRECT return code it is only helpful for interface internals.
So best to remove it rather than have it enshrined in UAPI
unnecessarily.

.John
