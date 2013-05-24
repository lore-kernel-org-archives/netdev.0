From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable when
 performing the upcall
Date: Fri, 24 May 2013 15:18:09 -0700
Message-ID: <CAEP_g=9Yqcf6_cpPYNAbiQUGjQa46PEz6gQdKAopiNNUDRhGYA@mail.gmail.com>
References: <cover.1369406826.git.tgraf@suug.ch> <064a09fffe48540b66a3ee503860ed9e8a1eb5f1.1369406826.git.tgraf@suug.ch>
 <CAEP_g=87CuiS92YtCZ1V1ME05qq0jGWD9p1WgKZ2jaaG1AWS7w@mail.gmail.com>
 <1369421900.3301.431.camel@edumazet-glaptop> <CAEP_g=898=iOWV15Y_bcjvS9sGSfDQSP1zQLNkffoXB5imdU7g@mail.gmail.com>
 <1369432621.3301.445.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:51258 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753417Ab3EXWSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 18:18:30 -0400
Received: by mail-ie0-f176.google.com with SMTP id at1so13316061iec.7
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 15:18:29 -0700 (PDT)
In-Reply-To: <1369432621.3301.445.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 24, 2013 at 2:57 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-05-24 at 14:23 -0700, Jesse Gross wrote:
>> On Fri, May 24, 2013 at 11:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Fri, 2013-05-24 at 10:24 -0700, Jesse Gross wrote:
>> >
>> >> Does this have any impact on small packets? Those are usually the
>> >> common case (i.e. TCP SYN) and I think this is slightly less optimal
>> >> for those.
>> >
>> > No difference at all, small packets are copied anyway in skb->head
>>
>> Yes, but it makes the Open vSwitch code slightly worse - for example,
>> currently checksumming and copying are done in a single step but this
>> prevents that. Actually, I'm also curious about the test case that was
>> used for large packets and the full profile output since checksumming
>> and GSO aren't listed in the one that Thomas gave.
>>
>
> GSO is fully supported in nfnetlink, I see no reason why Open vSwitch
> would not allow that.

Offloads are supported. What I want to know is how they affect
performance with this change.

>> My guess is that there isn't a real different for small packets since
>> everything will be in the cache but it seems worth checking given that
>> this is optimizing a rare case at the expense of the common one.
>
> I really doubt checksumming a SYN/ACK packet is that a performance
> issue. Do you have performance numbers ?
>
> You could always provide a patch to restore this copy/checksum if it
> really gives a benefit, and if people still use NIC not doing this
> checksum.

If it makes a difference then it needs to be addressed before this
patch goes in since it's the common case. I don't think it will but
that's why I'm asking for numbers.
