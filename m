From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH RFC iproute2] iplink: Support envhdrlen
Date: Sat, 1 Oct 2016 01:49:53 +0900
Message-ID: <9ed8fc87-85ba-c25f-1212-127aba0e9272@gmail.com>
References: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <1474966541-4420-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <20160929144944.609d5434@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jiri Benc <jbenc@redhat.com>,
        Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35974 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932646AbcI3Qt4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 12:49:56 -0400
Received: by mail-pa0-f68.google.com with SMTP id cd13so3177293pac.3
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 09:49:56 -0700 (PDT)
In-Reply-To: <20160929144944.609d5434@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/09/29 (木) 21:49, Jiri Benc wrote:
> On Tue, 27 Sep 2016 17:55:40 +0900, Toshiaki Makita wrote:
>> This adds support for envhdrlen.
>>
>> Example:
>>  # ip link set eno1 envhdrlen 8

Thank you for taking a look at this.

> I don't see why this should be user visible, let alone requiring user
> to set it. This should be transparent, kernel should compute the value
> as needed based on the configuration and set it up. Requiring the
> administrator to pick up a calculator and sum up all the vlan, mpls and
> whatever header lengths is silly.

I'm thinking both in-kernel automation (for VLAN) and users' manual 
operation are necessary. In fact, as I stated in the cover letter, my 
first implementation was an automation-based approach. Actually 
automation is advanced form of this feature so I'm proposing this very 
basic feature first.

> I realize that we currently have no easy way to do that. Especially
> with lwtunnels and stuff line MPLS where we don't easily know the
> number of tags. But every uAPI we introduce will have to be supported
> forever and going a particular way just because it is easy to implement
> is not sustainable.

It may be possible for MPLS lwtunnel to notify underlying device of 
needed header length. But at this point MPLS does not allow encapsulated 
packets to be greater than MTU of underlying device. So how to determine 
if someone wants to leverage envhdrlen instead? Add a knob to lwtunnel 
layer? Then, add another knob to l2tp, iptunnel, or anything like that? 
At least full-automation does not look possible other than VLAN (which 
by default requires envhdrlen expansion), so anyway manual operation is 
needed in some form.
Another use-case is reducing envhdrlen. We can expand it on creating 
VLAN device automatically, but cannot decrease the size because there 
could be other consumers of envhdrlen.

> At the very least, it should be configurable from the other direction.
> I.e. telling which interfaces can be used by vlans or MPLS (if it
> cannot be inferred automatically) and configuring maximum number of
> tags on the given vlan/mpls/whatever interface/route/whatever.

Probably I don't get your point...
Are you suggesting something like this?
$ ip link set eth0.10.20 expand-realdev-envhdrlen
or like this?
$ ip link set eth0 allowed-vlan-tags 2

Toshiaki Makita
