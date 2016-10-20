From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next] bpf: fix potential percpu map overcopy to
 user.
Date: Thu, 20 Oct 2016 21:39:49 +0200
Message-ID: <58091D85.9060701@iogearbox.net>
References: <1476636088-9268-1-git-send-email-u9012063@gmail.com> <20161019005004.GA87961@ast-mbp.thefacebook.com> <CALDO+SaebqahYHn2PU=nk6mYOMjRp+F8PKb3cFaGMv4_xjLwZg@mail.gmail.com> <58078E1D.6080108@iogearbox.net> <5808EB16.4000103@iogearbox.net> <20161020165807.GB97796@ast-mbp.thefacebook.com> <CALDO+SZbWbMPFsj10hR3XEB1696s0ENRoBttrT5T3O=DQ445XQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47820 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756485AbcJTTjw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 15:39:52 -0400
In-Reply-To: <CALDO+SZbWbMPFsj10hR3XEB1696s0ENRoBttrT5T3O=DQ445XQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2016 08:41 PM, William Tu wrote:
> On Thu, Oct 20, 2016 at 9:58 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Thu, Oct 20, 2016 at 06:04:38PM +0200, Daniel Borkmann wrote:
>>>
>>> diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
>>> index ee384f0..d4832e8 100644
>>> --- a/tools/testing/selftests/bpf/test_maps.c
>>> +++ b/tools/testing/selftests/bpf/test_maps.c
>>> @@ -25,6 +25,33 @@
>>>
>>>   static int map_flags;
>>>
>>> +static unsigned int num_possible_cpus(void)
>>> +{
>>> +     static const char *fcpu = "/sys/devices/system/cpu/possible";
>>> +     unsigned int val, possible_cpus = 0;
>>> +     char buff[128];
>>> +     FILE *fp;
>>> +
>>> +     fp = fopen(fcpu, "r");
>>> +     if (!fp) {
>>> +             printf("Failed to open %s: '%s'!\n", fcpu, strerror(errno));
>>> +             exit(1);
>>> +     }
>>> +
>>> +     while (fgets(buff, sizeof(buff), fp)) {
>>> +             if (sscanf(buff, "%*u-%u", &val) == 1)
>>> +                     possible_cpus = val;
>>> +     }
>>
>> looks great to me.
>> Could you move it into bpf_sys.h or somehow make it common in libbpf
>> and reuse it in samples/bpf/ ?
>> Since quite a few samples need this fix as well.

Ahh, true.

>> Thanks!
>
> Looks good to me. I tested it and it works fine.

Okay, thanks. I'll fix that up, mid-term we should try and move most of
that over to kernel selftests/bpf, and reuse tools/lib/bpf/.

> Thanks!
> William
