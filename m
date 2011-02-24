From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] cxgb{3,4}: streamline Kconfig options
Date: Thu, 24 Feb 2011 08:00:23 +0000
Message-ID: <4D661E2702000078000336B5@vpn.id2.novell.com>
References: <4D5D30CA020000780003263A@vpn.id2.novell.com>
 <20110222.101457.39195901.davem@davemloft.net>
 <4D64E5720200007800033420@vpn.id2.novell.com>
 <20110223.122709.193705956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <divy@chelsio.com>, <dm@chelsio.com>,
	<linux-kbuild@vger.kernel.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20110223.122709.193705956.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 23.02.11 at 21:27, David Miller <davem@davemloft.net> wrote:
> From: "Jan Beulich" <JBeulich@novell.com>
> Date: Wed, 23 Feb 2011 09:46:10 +0000
> 
>>>>> On 22.02.11 at 19:14, David Miller <davem@davemloft.net> wrote:
>>> From: "Jan Beulich" <JBeulich@novell.com>
>>> Date: Thu, 17 Feb 2011 13:29:30 +0000
>>> 
>>>> The CHELSIO_T{3,4}_DEPENDS options are really awkward, and can be
>>>> easily dropped if the reverse dependencies of SCSI_CXGB{3,4}_ISCSI on
>>>> the former get converted to normal (forward) ones referring to
>>>> CHELSIO_T{3,4}.
>>>> 
>>>> Signed-off-by: Jan Beulich <jbeulich@novell.com>
>>> 
>>> I think the goal of these strange rules is not to be complicated
>>> on purpose, but rather to cause the iSCSI drivers to appear without
>>> the user having to know that he needs to enable the networking
>>> driver in order for that to happen.
>> 
>> While I realize that this might have been the reason, it's completely
>> contrary to how everyone else writes dependencies, and hence I
>> think these should be removed.
> 
> If you knew you were changing the behavior of the config option in
> this way, you sure didn't think it was worth mentioning in your commit
> message.

I stated in the comment what I think this is - awkward.

> I definitely would never expect to have to enable a scsi option to get
> some network driver visible to enable in the config, and therefore I
> could see the opposite being insanely frustrating too.

The resulting dependency seems quite logical to me: Some higher
level networking functionality (iSCSI) depends on some lower level
networking functionality (an actual driver).

> You can't ignore these issues and just say "that's not the normal way
> so I'm going to change it anyways."

Admittedly I considered only my personal perspective.

Now, to get the whole discussion productive again - where do we
go from here? I don't think these drivers are so special that they
really need to behave backwards to how (almost?) everything else
is done... If changing it the way I did in the first try isn't deemed
acceptable, would it be at least acceptable to remove those
helper options (or, not as welcome from my perspective not the
least because of the odd dependency on INET instead of NET,
fold them into a single more generic one that others could also
benefit from)?

As to that INET vs NET dependency - is it possible that the
network drivers really just need NET, but the iSCSI ones need
INET? In which case the only common dependency would be
PCI - certainly not worth a custom helper option.

Jan

