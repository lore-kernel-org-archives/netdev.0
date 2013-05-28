From: Rik van Riel <riel@redhat.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Tue, 28 May 2013 17:30:02 -0400
Message-ID: <51A521DA.2080206@redhat.com>
References: <1369601101-23057-1-git-send-email-atomlin@redhat.com> <20130527224149.GA4384@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: atomlin@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	edumazet@google.com, pshelar@nicira.com, mst@redhat.com,
	alexander.h.duyck@intel.com, aquini@redhat.com,
	sergei.shtylyov@cogentembedded.com, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130527224149.GA4384@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/27/2013 06:41 PM, Francois Romieu wrote:
> atomlin@redhat.com <atomlin@redhat.com> :
> [...]
>> Failed GFP_ATOMIC allocations by the network stack result in dropped
>> packets, which will be received on a subsequent retransmit, and an
>> unnecessary, noisy warning with a kernel backtrace.
>>
>> These warnings are harmless, but they still cause users to panic and
>> file bug reports over dropped packets. It would be better to hide the
>> failed allocation warnings and backtraces, and let retransmits handle
>> dropped packets quietly.
>
> Linux VM may be perfect but device drivers do stupid things.
>
> Please don't paper over it just because some shit ends in your backyard.

It is impossible to free memory at the speed at which
10Gbit network packets can come in.

Dropped packets are a reality.

The network stack already has statistics counters to
keep track of dropped packets. There is absolutely
no reason to print out an entire kernel backtrace
for dropped network packets.

All that achieves is get people to file bug reports,
which nothing can be done about. Oh, and distract
them from whatever issue as causing their actual
problem, and delay them fixing what was going on.
