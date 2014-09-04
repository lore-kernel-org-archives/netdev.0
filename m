From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Wed, 3 Sep 2014 19:43:10 -0700
Message-ID: <CAADnVQLh6qOD2epUq0S5P8RkUgZA38JNxeP40uBMScLHC2SsJg@mail.gmail.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
	<54078FBC.5050402@redhat.com>
	<CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
	<1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409793959.3362714.163402573.6A26EDE1@webmail.messagingengine.com>
	<1409796348.26422.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:50636 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595AbaIDCnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 22:43:11 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so9635131qcx.41
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 19:43:10 -0700 (PDT)
In-Reply-To: <1409796348.26422.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014 at 7:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-09-04 at 03:25 +0200, Hannes Frederic Sowa wrote:
>
>> Can't we add an address marker to struct sk_buff?
>>
>> Several possibilities are available:
>>
>> ptrdiff_t pkt_type_offset[0]  before the pkt_type flags field
>>
>> If one wants to make it more expressive:
>> typedef struct {} mark_struct_offset;
>> and add
>> mark_struct_offset pkt_type_offset;
>> at appropriate places
>>
>> Or maybe an anonymous union?
>>
>> pkt_type_offset would become a simple offsetof(struct sk_buff,
>> pkt_type_offset) then and there is no need for BUG_ON then.
>
>
> You can try, and make sure this works on all gcc compilers, even the one
> Andrew Morton uses.
>
> And of course, you need to not introduce holes doing so.

good points.
I think Hannes's idea is the best. It will help to get rid of helper altogether.
For my bpf syscall proposal I've used anonymous unions and tested
them with gcc 4.2 - 4.9 on x64/i386/arm32/sparc64 and clang.
All compilers were doing just fine. So it should work.
