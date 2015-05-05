From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 6/6] mpls: Add MPLS entropy label in flow_keys
Date: Mon, 4 May 2015 19:13:44 -0700
Message-ID: <CALx6S35E7B6efmvOy11O7QDEr_g52cN=5By2PNuq2sq359Ezhw@mail.gmail.com>
References: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
	<1430780560-2758924-7-git-send-email-tom@herbertland.com>
	<20150505005609.GA14825@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:33860 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbbEECNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 22:13:44 -0400
Received: by iget9 with SMTP id t9so77802728ige.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 19:13:44 -0700 (PDT)
In-Reply-To: <20150505005609.GA14825@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 4, 2015 at 5:56 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, May 04, 2015 at 04:02:40PM -0700, Tom Herbert wrote:
>> In flow dissector if an MPLS header contains an entropy label this is
>> saved in the new extra entropy field of flow_keys. The entropy label is
>> then represented in the flow hash function input.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>> ---
>>  include/uapi/linux/in.h   |  2 ++
>>  include/uapi/linux/mpls.h |  3 +++
>>  net/core/flow_dissector.c | 27 +++++++++++++++++++++++++++
>>  3 files changed, 32 insertions(+)
>>
>> diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
>> index 589ced0..c86f6ab 100644
>> --- a/include/uapi/linux/in.h
>> +++ b/include/uapi/linux/in.h
>> @@ -69,6 +69,8 @@ enum {
>>  #define IPPROTO_SCTP         IPPROTO_SCTP
>>    IPPROTO_UDPLITE = 136,     /* UDP-Lite (RFC 3828)                  */
>>  #define IPPROTO_UDPLITE              IPPROTO_UDPLITE
>> +  IPPROTO_MPLS = 137,                /* MPLS in IP (RFC 4023)                */
>> +#define IPPROTO_MPLS         IPPROTO_SCTP
>
> odd typo. was it tested?
>
Yep, that's a typo. Also noticed that LABEL_ENTROPY_INDICATOR is
defined also in internal.h (shouldn't reserved labels be in uapi?).
Not tested, we need a way to do MPLS over IP for that!
