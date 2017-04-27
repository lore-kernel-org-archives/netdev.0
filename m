From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 4/6] bpf: track if the bpf program was loaded
 with SYS_ADMIN capabilities
Date: Thu, 27 Apr 2017 15:17:55 +0200
Message-ID: <eaa0c158-1743-2793-1ea3-18aecd9d0ad5@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
 <20170426182419.14574-5-hannes@stressinduktion.org>
 <20170426210826.mlwuuhq7jsu4n7f4@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.com,
        jbenc@redhat.com, aconole@bytheb.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:54747 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751550AbdD0NR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 09:17:58 -0400
In-Reply-To: <20170426210826.mlwuuhq7jsu4n7f4@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 26.04.2017 23:08, Alexei Starovoitov wrote:
> On Wed, Apr 26, 2017 at 08:24:17PM +0200, Hannes Frederic Sowa wrote:
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>  include/linux/filter.h | 6 ++++--
>>  kernel/bpf/core.c      | 4 +++-
>>  kernel/bpf/syscall.c   | 7 ++++---
>>  kernel/bpf/verifier.c  | 4 ++--
>>  net/core/filter.c      | 6 +++---
>>  5 files changed, 16 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index 63624c619e371b..635311f57bf24f 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> @@ -413,7 +413,8 @@ struct bpf_prog {
>>  				locked:1,	/* Program image locked? */
>>  				gpl_compatible:1, /* Is filter GPL compatible? */
>>  				cb_access:1,	/* Is control block accessed? */
>> -				dst_needed:1;	/* Do we need dst entry? */
>> +				dst_needed:1,	/* Do we need dst entry? */
>> +				priv_cap_sys_admin:1; /* Where we loaded as sys_admin? */
> 
> This is no go.
> You didn't provide any explanation whatsoever why you want to see this boolean value.

Sorry, should be in the description and will be added if this patch
series is considered to be worthwhile to pursue.

cap_sys_admin influences the verifier a lot in terms which programs are
accepted and which are not. So during investigations it might be even
interesting if the bpf program required those special flags or if the
same program could be loaded just as underprivileged.

I also have to review if we can/should attach cap_sys_admin verified
programs as unprivileged user. It should stop to install a ptr leaking
bpf program as ordinary user, even if one got the file descriptor, no?

Bye,
Hannes
