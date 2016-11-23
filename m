From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/1] ipv6: sr: add option to control lwtunnel
 support
Date: Wed, 23 Nov 2016 06:57:44 -0800
Message-ID: <5835AE68.3060003@cumulusnetworks.com>
References: <CAADnVQ+MdPeZv1FpzD=omH1ftr2vW3uYiqdLL3Y_teaZj=tEbQ@mail.gmail.com> <5835466B.6080405@cumulusnetworks.com> <5835613D.8070104@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34834 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937116AbcKWO7Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:59:16 -0500
Received: by mail-pf0-f169.google.com with SMTP id i88so3986247pfk.2
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:57:45 -0800 (PST)
In-Reply-To: <5835613D.8070104@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/16, 1:28 AM, David Lebrun wrote:
> On 11/23/2016 08:34 AM, Roopa Prabhu wrote:
>> I can't seem to reproduce the problem you are seeing. still trying..
>> I don't have CONFIG_LWTUNNEL set nor any of the other SEG6 configs.
>> My CONFIG_IPV6 is on and compiled as a module. I have also tried disabling it.
>> If you can send me the config, I can try again. Looking back at the patches,
>> I do see a few things below ..but they may not fix your problem directly.
>>
>> Though I had none of the ipv6 segment routing configs turned on,
>> I do see the "Segment Routing with IPv6" msg at bootup.
>> Was looking at david's patches again, and a few things (I had missed seeing the last version):
>>
>> In my review comment I was hinting at CONFIG_IPV6_SEG6 to cover all of ipv6 segment routing,
>> including the lwtunnel bits.
>>
>> something like below:
>>
>> config IPV6_SEG6
>>         bool "IPv6: Segment Routing Header encapsulation support"
>>         depends on LWTUNNEL && IPV6
>>
>> DavidL, do you see a problem doing it this way ?. with this 'seg6.o' will be part of CONFIG_IPV6_SEG6 and not
>> get initialized unless it is enabled..which seems like the right thing to do.
> Can't reproduce the bug either, with CONFIG_IPV6=y, LWTUNNEL=n and all
> SEG6 disabled. Alexei, your .config and dmesg log could help.
>
> Roopa, the reason why seg6.o is compiled by default is that it provides
> an interface to control HMAC structures, and that HMAC does not depends
> on lwtunnels and can be used in the extension header processing (which
> is compiled by default). I could indeed add another option to
> conditionnally compile seg6.o if HMAC is enabled etc, and I actually had
> something like that in the very first versions of the patch, but I
> received comments that too much options is not a good thing (and I agree
> with that).

okay then. I agree with not having too many option. I had just thought that it
could live with the existing CONFIG_IPV6_SEG6_LWTUNNEL if it was renamed.
had not  looked at the HMAC dependency.
