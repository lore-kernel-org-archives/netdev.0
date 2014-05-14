From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH net-next v2] net: filter: add insn for loading internal
 transport header offset
Date: Wed, 14 May 2014 11:42:56 -0700
Message-ID: <CA+ZOOTMxDnqVRFn52iKRBdM-KeNE=nk5Phnh1m4S1CwPaJQe+A@mail.gmail.com>
References: <CA+ZOOTP88BJ-keuR5NznCgbDVPyzugWkdsVYjKkk5yGOBbkddQ@mail.gmail.com>
	<20140502.225252.1865694187680020950.davem@davemloft.net>
	<CA+ZOOTNQJ59VrFhrtGT7EzhL7u0FnupuwOLqv-rJ0jQi2CP8Jg@mail.gmail.com>
	<20140505.151200.705079679797479652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35841 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbaENSm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 14:42:57 -0400
Received: by mail-ie0-f174.google.com with SMTP id at1so2272967iec.19
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 11:42:56 -0700 (PDT)
In-Reply-To: <20140505.151200.705079679797479652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 5, 2014 at 12:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Chema Gonzalez <chema@google.com>
> Date: Mon, 5 May 2014 11:42:00 -0700
>
>> On Fri, May 2, 2014 at 7:52 PM, David Miller <davem@davemloft.net> wrote:
>>> We can probably add an extension to AF_PACKET which provides the flow
>>> key at the end of the tpacket3_hdr if a certain socket option is set.
>>>
>>> That would provide the transport header as well as a side effect, and
>>> be much more powerful and efficient than this particular BPF
>>> instruction.
>> I'm not sure whether I follow this. The goal is to be able to access
>> the inner-most headers inside BPF, not in userland by calling
>> getsockopt().
>
> You're missing my entire point.
>
> You can use AF_PACKET mmap() rings and in those ring entries all of the
> flow dissection information can be put in the ring entry headers before
> the packet contents.  Ports, header offsets, everything.
I added a flow_keys variable in the packet runner function
(__sk_run_filter()) stack, and modified __skb_get_poff() to try to get
the results from there instead of calling the flow dissector every
time you call it. That will allow the packet filter to only perform a
single call to the flow dissector per packet.

I reworked the toff patch to use the same flow dissector output
approach (and share it with the poff load), and added a tproto patch.

Patches coming now.

-Chema
