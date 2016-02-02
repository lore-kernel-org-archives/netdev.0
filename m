From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] tc: fix compilation with old gcc (< 4.6) (bis)
Date: Tue, 2 Feb 2016 11:39:28 +0100
Message-ID: <56B08760.7040204@6wind.com>
References: <1f5ba49033cd4c55a0d0005487efde39@HQ1WP-EXMB11.corp.brocade.com>
 <20160202155157.2f492bfd@samsung9> <56B07216.5080604@iogearbox.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36289 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529AbcBBKjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:48 -0500
Received: by mail-wm0-f50.google.com with SMTP id p63so111091535wmp.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 02:39:47 -0800 (PST)
In-Reply-To: <56B07216.5080604@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/02/2016 10:08, Daniel Borkmann a =E9crit :
> On 02/02/2016 05:51 AM, Stephen Hemminger wrote:
>> On Tue, 19 Jan 2016 11:01:45 +0000
>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>
>>> diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
>>> index 42c8841869f5..219ffa582c1a 100644
>>> --- a/tc/tc_bpf.c
>>> +++ b/tc/tc_bpf.c
>>> @@ -49,6 +49,10 @@
>>>   #include "tc_util.h"
>>>   #include "tc_bpf.h"
>>>
>>> +#ifndef AF_ALG
>>> +#define AF_ALG 38
>>> +#endif
>>
>> Why is this here? AF_ALG is not used anywhere in this code.
>
> It is used, this patch is fine as-is.
Yes, it's used and not defined with old toolchains:
$ git grep AF_ALG
tc/tc_bpf.c:#ifndef AF_ALG
tc/tc_bpf.c:#define AF_ALG 38
tc/tc_bpf.c:            .salg_family    =3D AF_ALG,
tc/tc_bpf.c:    cfd =3D socket(AF_ALG, SOCK_SEQPACKET, 0);
tc/tc_bpf.c:            fprintf(stderr, "Cannot get AF_ALG socket: %s\n=
",

Regards,
Nicolas
