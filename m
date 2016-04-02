From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 0/5] Add driver bpf hook for early packet drop
Date: Sat, 2 Apr 2016 18:57:09 -0400
Message-ID: <CALx6S35kK9eNk8r-fZmP-mOSB=Tb8udbaQeSUjmHWJagh+=i=A@mail.gmail.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459622491.18188.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	gerlitz@mellanox.com, Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Lorenzo Colitti <lorenzo@google.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33445 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcDBW5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 18:57:10 -0400
Received: by mail-ig0-f181.google.com with SMTP id ma7so39379132igc.0
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 15:57:10 -0700 (PDT)
In-Reply-To: <1459622491.18188.6.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 2, 2016 at 2:41 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Fri, 2016-04-01 at 18:21 -0700, Brenden Blanco wrote:
>> This patch set introduces new infrastructure for programmatically
>> processing packets in the earliest stages of rx, as part of an effort
>> others are calling Express Data Path (XDP) [1]. Start this effort by
>> introducing a new bpf program type for early packet filtering, before
>> even
>> an skb has been allocated.
>>
>> With this, hope to enable line rate filtering, with this initial
>> implementation providing drop/allow action only.
>
> Since this is handed to the driver in some way, I assume the API would
> also allow offloading the program to the NIC itself, and as such be
> useful for what Android wants to do to save power in wireless?
>
Conceptually, yes. There is some ongoing work to offload BPF and one
goal is that BPF programs (like for XDP) could be portable between
userspace, kernel (maybe even other OSes), and devices.

I am curious though, how do you think this would specifically help
Android with power? Seems like the receiver still needs to be powered
to receive packets to filter them anyway...

Thanks,
Tom

> johannes
