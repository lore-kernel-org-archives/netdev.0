From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH v2 iproute2] tc: fix bpf compilation with old glibc
Date: Mon, 27 Jul 2015 10:09:47 +0200
Message-ID: <CAGm1_kvtxPqtnMcW42H-05M6-kPYz3SZ_YUvHN11=dPR7DTqPw@mail.gmail.com>
References: <20150722094702.2eb3c0ea@urahara> <1437635861-19157-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150723215026.GB31886@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vn0-f51.google.com ([209.85.216.51]:35872 "EHLO
	mail-vn0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbbG0IKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:10:07 -0400
Received: by vnk197 with SMTP id 197so28046787vnk.3
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 01:10:06 -0700 (PDT)
In-Reply-To: <20150723215026.GB31886@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 11:50 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Jul 23, 2015 at 09:17:41AM +0200, Nicolas Dichtel wrote:
>> Error was:
>> f_bpf.o: In function `bpf_parse_opt':
>> f_bpf.c:(.text+0x88f): undefined reference to `secure_getenv'
>> m_bpf.o: In function `parse_bpf':
>> m_bpf.c:(.text+0x587): undefined reference to `secure_getenv'
>> collect2: error: ld returned 1 exit status
>>
>> There is no special reason to use the secure version of getenv, thus let's
>> simply use getenv().
>>
>> CC: Daniel Borkmann <daniel@iogearbox.net>
>> Fixes: 88eea5395483 ("tc: {f,m}_bpf: allow to retrieve uds path from env")
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>
>> v2: rework the fix to use getenv() instead of secure_getenv()
>
> had the same workaround locally.
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Tested-by: Yegor Yefremov <yegorslists@googlemail.com>

tested with uclibc, that has problems with secure_getenv() too.

Yegor
