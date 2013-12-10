From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] net: ovs: use CRC32 accelerated flow hash if available
Date: Tue, 10 Dec 2013 13:40:39 -0800
Message-ID: <CAEP_g=9m9iSM8eKrTCfZpomRGKJA7+cLG8KQOzpuVGCDAr7gsg@mail.gmail.com>
References: <1386669178-14450-1-git-send-email-ffusco@redhat.com>
 <CAEP_g=_t750s50-F7A_hWD_yNs3MnKWN8WDBjzgoF8Mu+28Wyw@mail.gmail.com>
 <20131210.143652.1279430126319061689.davem@davemloft.net> <CA+mtBx_FPUf=K=tBKmwe8-r7OsgiMS8VE6bYpyQa+OY7Cn=MaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Francesco Fusco <ffusco@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:46595 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751333Ab3LJVlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 16:41:00 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so9733294iej.12
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 13:41:00 -0800 (PST)
In-Reply-To: <CA+mtBx_FPUf=K=tBKmwe8-r7OsgiMS8VE6bYpyQa+OY7Cn=MaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 1:27 PM, Tom Herbert <therbert@google.com> wrote:
> On Tue, Dec 10, 2013 at 11:36 AM, David Miller <davem@davemloft.net> wrote:
>> From: Jesse Gross <jesse@nicira.com>
>> Date: Tue, 10 Dec 2013 11:28:08 -0800
>>
>>> I think this is definitely a good optimization to do given that so
>>> much of the work that OVS does is hashing. However, isn't there a
>>> library where there would be a more appropriate place to put this?
>>
>> I also honestly don't see why we want to special case OVS at all
>> here.  This faster hashing would be useful for socket demux and
>> other locations in the kernel.
>>
>
> Also, we already do a lot of work to compute flow hashes for packets
> in both TX and RX.  Can these be leveraged? For instance, if OVS is
> computing a 5-tuple hash on an RX packet it's probably redundant to
> skb->rxhash.

That's true if we care about exactly the 5-tuple. However, the set of
fields that are included in the OVS flow lookup is dynamically
generated down to a bit mask so I don't know if it's worth special
casing. (In fact, I don't think that current OVS userspace will ever
actually emit exactly a 5-tuple.)
