From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 3/3] vxlan: virtual extensible lan
Date: Thu, 4 Oct 2012 09:25:48 -0700
Message-ID: <CAEP_g=8rTugVHVjWH+KRS3kMTV1rHgA1GKVmNXsM7r1uKLbV9A@mail.gmail.com>
References: <20121001223232.566037595@vyatta.com> <20121001223254.349753999@vyatta.com>
 <CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
 <20121003210220.5e74aa5d@nehalam.linuxnetplumber.net> <1349332490.16011.16.camel@edumazet-glaptop>
 <20121004081214.7f5a48fe@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:35028 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933406Ab2JDQ0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 12:26:11 -0400
Received: by mail-ob0-f174.google.com with SMTP id uo13so645400obb.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 09:26:09 -0700 (PDT)
In-Reply-To: <20121004081214.7f5a48fe@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 4, 2012 at 8:12 AM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Thu, 04 Oct 2012 08:34:50 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> On Wed, 2012-10-03 at 21:02 -0700, Stephen Hemminger wrote:
>>
>> >
>> > Since port is always a pair, there is no need to restrict range, unless
>> > there was a broken firewall in the way. One bug there is that random32()
>> > can return 0 which is not a valid port number.  A better fallback
>> > would be a hash of the MAC header.
>>
>> But using up to 65536 values for the port means that if vxlan traffic
>> crosses a statefull firewall (eg netfilter with conntrack), this might
>> need 65536 contexts/sessions.
>
> This is UDP, there is no usable state to be found.
> But as a practical matter it only needs to be wide enough to hit the
> number of receive channels. Therefore even 64 is probably enough for
> most people.

I don't think it actually matters all that much either way because
there will be one vxlan flow for each encapsulated flow.  If you're
running iptables on a hypervisor, for example, you probably end up
seeing the same number of flows as you do today.

There is some benefit to using a slightly wider range than the number
of paths you can take because devices in the path will do their own
hash.  Having a larger range on the vxlan side will reduce the impact
of collisions in the second hash.

>> So random32() is not needed.
>>
>> What might be needed is additional parameters for a vxlan tunnel, to
>> give an optional range for the source port.
>
> It could be per vxlan without a lot of pain. or just derive it value
> from existing ephermeral port range.

In the STT draft we recommended using the ephemeral range.  It seemed
like a good balance.
