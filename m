From: Y Song <ys114321@gmail.com>
Subject: Re: running an eBPF program
Date: Sun, 28 May 2017 22:31:36 -0700
Message-ID: <CAH3MdRVk5J2T+L7wOg4FmkWiR58JNqUPTZ+Eq-ZzGhaKVMYJBQ@mail.gmail.com>
References: <CAErYV9EjKGh9ta8TZ9PRmaATH5VcXQH4cd=WuL5NfMOpcuoLfw@mail.gmail.com>
 <CAH3MdRVMixv8s10gKF1jQjtSY7MHeB-Rs16hX6HwAgUOQ0g=EA@mail.gmail.com>
 <CAH3MdRWg57Aw666ahVGb04UcSTqxrz1Wd33JDLyCqY4fh=xstA@mail.gmail.com>
 <20170527.201107.1558140531080967167.davem@davemloft.net> <CAH3MdRUukbz+hy76afQiHi=k-_CsA12ShjaoQKnFcLnoVxBHPQ@mail.gmail.com>
 <CAErYV9FSQ1Fs-++1MPGXh=_aY3PnBKKCLTH_rvxGWaaz=6aBNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: Adel Fuchs <adelfuchs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:33988 "EHLO
        mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750994AbdE2FcR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 01:32:17 -0400
Received: by mail-vk0-f43.google.com with SMTP id y190so26857580vkc.1
        for <netdev@vger.kernel.org>; Sun, 28 May 2017 22:32:16 -0700 (PDT)
In-Reply-To: <CAErYV9FSQ1Fs-++1MPGXh=_aY3PnBKKCLTH_rvxGWaaz=6aBNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 28, 2017 at 12:38 AM, Adel Fuchs <adelfuchs@gmail.com> wrote:
> Hi,
> Is there any way to run this eBPF program without that patch?
> Alternatively, is there any other eBPF sample that does run properly? I need
> to run a program that filters packets according to IP address or port.

The following is temporary workaround you can use:
        int poff, nh_off = BPF_LL_OFF + ETH_HLEN;
-       __be16 proto = skb->protocol;
+       __be16 proto = (__be16)*(volatile __u32 *)&skb->protocol;
        __u8 ip_proto;
