From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] sctp: chunkmap size is too large
Date: Wed, 4 Feb 2009 11:12:47 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902041112030.17765@fbirervta.pbzchgretzou.qr>
References: <4983200B.2080707@6wind.com> <20090201.011427.38305360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: olivier.matz@6wind.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, kaber@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090201.011427.38305360.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sunday 2009-02-01 10:14, David Miller wrote:
>> I think that the chunkmap field in struct xt_sctp_info is
>> too large: we have 256 chunk types and it's a bitfield,
>> so the table should be 256 bits (8 uint32_t) instead
>> of 64 uint32_t.
>> 
>> I updated the size of the table, and I did some cosmetic
>> changes in SCTP_CHUNKMAP_* macros (use a mask instead of
>> a modulo).
>> 
>>   netfilter/xt_sctp.h       |   30 ++++++++++++++++--------------
>>   netfilter_ipv4/ipt_sctp.h |   30 ++++++++++++++++--------------
>>   2 files changed, 32 insertions(+), 28 deletions(-)
>> 
>> Can someone have a look at it ? Please CC me for any replies
>> as I'm not on the list.
>
>Patrick, I assume you got this?

At least I got this - and the change would have to be nak'ed because
it changes the userspace<->kernel binary stream. If you do such a
change, a new match revision is required.
