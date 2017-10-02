From: enh <enh@google.com>
Subject: Re: [PATCH iproute2] iproute: build more easily on Android
Date: Mon, 2 Oct 2017 13:23:26 -0700
Message-ID: <CAJgzZor7VMuTWgRUvVp_q=DHEm5bdgHNWxBJ3wG+X9GWTEwB7Q@mail.gmail.com>
References: <20171002170337.42235-1-lorenzo@google.com> <20171002103611.17ccb01f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:51975 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdJBUXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 16:23:48 -0400
Received: by mail-oi0-f43.google.com with SMTP id n82so11002345oib.8
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 13:23:47 -0700 (PDT)
In-Reply-To: <20171002103611.17ccb01f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 2, 2017 at 10:36 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue,  3 Oct 2017 02:03:37 +0900
> Lorenzo Colitti <lorenzo@google.com> wrote:
>
>> iproute2 contains a bunch of kernel headers, including uapi ones.
>> Android's libc uses uapi headers almost directly, and uses a
>> script to fix kernel types that don't match what userspace
>> expects.
>>
>> For example: https://issuetracker.google.com/36987220 reports
>> that our struct ip_mreq_source contains "__be32 imr_multiaddr"
>> rather than "struct in_addr imr_multiaddr". The script addresses
>> this by replacing the uapi struct definition with a #include
>> <bits/ip_mreq.h> which contains the traditional userspace
>> definition.
>>
>> Unfortunately, when we compile iproute2, this definition
>> conflicts with the one in iproute2's linux/in.h.
>>
>> Historically we've just solved this problem by running "git rm"
>> on all the iproute2 include/linux headers that break Android's
>> libc.  However, deleting the files in this way makes it harder to
>> keep up with upstream, because every upstream change to
>> an include file causes a merge conflict with the delete.
>>
>> This patch fixes the problem by moving the iproute2 linux headers
>> from include/linux to include/uapi/linux.
>>
>> Tested: compiles on ubuntu trusty (glibc)
>>
>> Signed-off-by: Elliott Hughes <enh@google.com>
>> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
>
> Rather than moving everything, why not make kernel headers directory
> configurable as part of the configure script setup process.

the problem is that C libraries with their our own uapi headers still
need your app-specific headers. to build iproute2 we need to put
iproute2's include/ on our include path, but then the fact that your
different uapi headers are *under* that directory causes the conflict.
separating your headers from your copy of the uapi headers is a
necessary part of any fix.

-- 
Elliott Hughes - http://who/enh - http://jessies.org/~enh/
Android native code/tools questions? Mail me/drop by/add me as a reviewer.
