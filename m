From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH] bpf: fix size of copy_to_user in percpu map.
Date: Thu, 18 Aug 2016 18:38:20 -0700
Message-ID: <CALDO+Sa6P-Qo5OqJELcak2nUKMAwdMuAxrDKASCJ_oJRPFsKjQ@mail.gmail.com>
References: <20160729064722.GA54517@ast-mbp.thefacebook.com>
 <579B0B9F.8040805@iogearbox.net> <CALDO+SZueK9ymNjrLAK+00xzR_BTms+qVhy0DAPnJZGrken2rg@mail.gmail.com>
 <579BF2A1.7000709@iogearbox.net> <CALDO+SbhCuc85b=UuSWVc7baScN+MNwwaLKcXeubPL1SJvOT=Q@mail.gmail.com>
 <20160730053415.GA78880@ast-mbp.thefacebook.com> <CALDO+SaVhA4GB+=-LnbZpWyx15wgc8PRFXVD4dO-O5kb+hJE9g@mail.gmail.com>
 <20160801160738.GA99707@ast-mbp.thefacebook.com> <CALDO+SbcTh9Gd75wrJRUvo7SG-kCaKDk8fteQKndTz+_NnAccw@mail.gmail.com>
 <CALDO+SbrUBa0JpGTbX2cFs3rVhchPtSOmw=Jwjb26fkQ=w0qmg@mail.gmail.com> <20160812230810.GB48651@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34238 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754160AbcHSBjg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:39:36 -0400
Received: by mail-it0-f67.google.com with SMTP id e63so747110ith.1
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 18:39:01 -0700 (PDT)
In-Reply-To: <20160812230810.GB48651@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei and Daniel,

I got feedback from Fusion bios/chipset team. In short, the value
'possible' includes empty CPU socket. To verify, I tested on a
physical Xeon machine with 2 CPU sockets, one of them is empty. I got
'possible' = 0-239, the number of 'cpu*' =12. As a result, extra bytes
are copied from kernel to userspace.

As for Fusion, there is a configuration in *.vmx. If we disable cpu
hot plug by "vcpu.hotadd=FALSE", then 'possible' ==  the number of
'cpu*' dirs, which is the configuration in ESX. If "vcpu.hotadd=TURE",
then 'possible' is larger than 'cpu*' dirs, allowing users to add more
vcpus.

Regards,
William


On Fri, Aug 12, 2016 at 4:08 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Aug 12, 2016 at 09:58:51AM -0700, William Tu wrote:
>> Hi,
>>
>> I've tested on ESXi version 5.5 and it seems OK.
>> - VM1: Ubuntu 14.04, kernel 3.19 ---> OK 3 cpu dirs, possible = 0-2
>> - VM2: Centos7, kernel 3.10 ---> OK 8 cpu dirs, possible = 0-7
>>
>> I tried another MacBook with Fusion, same issue happens, the cpu[0-9]
>> dirs are not equal to /sys/devices/system/cpu/possible
>
> great. thanks for testing. I think the issue is closed and
> hopefully you can follow up with fusion guys ;)
>
