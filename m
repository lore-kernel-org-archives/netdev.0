From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/1] ipv6: sr: add option to control lwtunnel
 support
Date: Wed, 23 Nov 2016 18:31:01 -0800
Message-ID: <20161124023059.GA54877@ast-mbp.thefacebook.com>
References: <CAADnVQ+MdPeZv1FpzD=omH1ftr2vW3uYiqdLL3Y_teaZj=tEbQ@mail.gmail.com>
 <5835466B.6080405@cumulusnetworks.com>
 <5835613D.8070104@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36259 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbcKXCbG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 21:31:06 -0500
Received: by mail-pg0-f67.google.com with SMTP id x23so2300743pgx.3
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 18:31:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5835613D.8070104@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 10:28:29AM +0100, David Lebrun wrote:
> On 11/23/2016 08:34 AM, Roopa Prabhu wrote:
> > I can't seem to reproduce the problem you are seeing. still trying..
> > I don't have CONFIG_LWTUNNEL set nor any of the other SEG6 configs.
> > My CONFIG_IPV6 is on and compiled as a module. I have also tried disabling it.
> > If you can send me the config, I can try again. Looking back at the patches,
> > I do see a few things below ..but they may not fix your problem directly.
> > 
> > Though I had none of the ipv6 segment routing configs turned on,
> > I do see the "Segment Routing with IPv6" msg at bootup.
> > Was looking at david's patches again, and a few things (I had missed seeing the last version):
> > 
> > In my review comment I was hinting at CONFIG_IPV6_SEG6 to cover all of ipv6 segment routing,
> > including the lwtunnel bits.
> > 
> > something like below:
> > 
> > config IPV6_SEG6
> >         bool "IPv6: Segment Routing Header encapsulation support"
> >         depends on LWTUNNEL && IPV6
> > 
> > DavidL, do you see a problem doing it this way ?. with this 'seg6.o' will be part of CONFIG_IPV6_SEG6 and not
> > get initialized unless it is enabled..which seems like the right thing to do.
> 
> Can't reproduce the bug either, with CONFIG_IPV6=y, LWTUNNEL=n and all
> SEG6 disabled. Alexei, your .config and dmesg log could help.

I didn't save that .config and did bisect of the other bug that
messed up my .confg. Now I cannot reproduce it. Sorry for the noise.
Still weird though that ping prefers ipv6 address now.
$ ping localhost
PING localhost(localhost.localdomain (::1)) 56 data bytes
64 bytes from localhost.localdomain (::1): icmp_seq=1 ttl=64 time=0.043 ms
