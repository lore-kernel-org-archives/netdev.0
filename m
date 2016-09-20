From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in vxlan_build_skb()
Date: Tue, 20 Sep 2016 10:19:16 -0700
Message-ID: <CALx6S37aCze6YvCAA18DR8TTkaO-fCtdVeof7Naa9yh+HJZG+A@mail.gmail.com>
References: <20160920142700.GJ8920@oracle.com> <20160920181114.0ac7cfa0@griffin>
 <20160920163108.GP8920@oracle.com> <20160920184333.17444823@griffin> <20160920190929.57ddaeb0@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Paolo Abeni <pabeni@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:36012 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbcITRTR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 13:19:17 -0400
Received: by mail-qt0-f170.google.com with SMTP id l91so10682132qte.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 10:19:17 -0700 (PDT)
In-Reply-To: <20160920190929.57ddaeb0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 10:09 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 20 Sep 2016 18:43:33 +0200, Jiri Benc wrote:
>> On Tue, 20 Sep 2016 12:31:08 -0400, Sowmini Varadhan wrote:
>> > The vxlan header is after the ethernet header (14 bytes),
>> > IP header (20 bytes, assuming no options) and udp header (8 bytes).
>>
>> If the VXLAN header is not aligned to 4 bytes, then IP header is not
>> aligned to 4 bytes, too, and you have greater problems than just VXLAN.
>
> ...which is indeed the case. Sorry, I guess I'm too much focused on
> VXLAN-GPE nowadays and I missed that we're building this before the
> inner Ethernet header.
>
> But the point stands, we have much greater problems here than VXLAN.
> And I don't think that wrapping all IP address accesses into
> get/put_unaligned all around the stack is the solution.
>
RIght, this is problem with the encapsulations themselves. IP
protocols are supposed to be four-byte aligned and Ethernet
encapsulation is obviously breaking that. We can't address this in
existing standards like GRE-TEB, but for new encapsulations we should
make sure this avoided. I've posted on nvo3 list about this issue.

Tom

>  Jiri
