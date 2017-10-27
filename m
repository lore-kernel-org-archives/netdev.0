From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] tcp: add tracepoint
 trace_tcp_retransmit_synack()
Date: Fri, 27 Oct 2017 12:57:53 -0700
Message-ID: <6257e78f-4423-ddd3-422d-2bd818a83be0@fb.com>
References: <201710261134.MUf5E7cp%fengguang.wu@intel.com>
 <2552809E-4EBC-4F3D-94A4-41BE0ECB27C2@fb.com>
 <CAM_iQpVzGpype9ytprzF9zcigZ6ckE03SYnGPdfSxUQRgqV82Q@mail.gmail.com>
 <D81267F3-4447-4375-B2A8-06F92FAF4ACD@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild test robot <lkp@intel.com>,
        David Miller <davem@davemloft.net>,
        "kbuild-all@01.org" <kbuild-all@01.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        Martin Lau <kafai@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "liu.song.a23@gmail.com" <liu.song.a23@gmail.com>
To: Song Liu <songliubraving@fb.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55966 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932428AbdJ0T6F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 15:58:05 -0400
In-Reply-To: <D81267F3-4447-4375-B2A8-06F92FAF4ACD@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/17 10:06 PM, Song Liu wrote:
>
>> On Oct 26, 2017, at 7:01 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>
>> On Thu, Oct 26, 2017 at 4:50 PM, Song Liu <songliubraving@fb.com> wrote:
>>> In this case, we are putting CONFIG_IPV6 in TRACE_EVENT macro, which generates
>>> warnings like:
>>>
>>> ./include/trace/events/tcp.h:274:1: error: directive in argument list
>>> ./include/trace/events/tcp.h:281:1: error: directive in argument list
>>>
>>> Seems these warning cannot be easily avoided. This is also the same pattern we
>>> have been using in include/trace/events/tcp.h.
>>
>> Hmm, we use the same so why it only complains about this one?\
>
> sparse reports same warning for all the lines in tcp.h. Don't know why
> kbuild test bot only complains about this patch.

it's safe to ignore this sparse error.
The #ifdef inside TP_fast_assign() in net.h have been there for years
without issues.
$ make C=2 net/core/dev.o
../include/trace/events/net.h:170:1: error: directive in argument list
../include/trace/events/net.h:172:1: error: directive in argument list
../include/trace/events/net.h:174:1: error: directive in argument list
