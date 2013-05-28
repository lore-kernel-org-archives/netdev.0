From: Ben Greear <greearb@candelatech.com>
Subject: Re: [Patch v2] skbuff: Hide GFP_ATOMIC page allocation failures for
 dropped packets
Date: Tue, 28 May 2013 09:00:45 -0700
Message-ID: <51A4D4AD.2010507@candelatech.com>
References: <1369601101-23057-1-git-send-email-atomlin@redhat.com> <20130527224149.GA4384@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: atomlin@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	edumazet@google.com, pshelar@nicira.com, mst@redhat.com,
	alexander.h.duyck@intel.com, riel@redhat.com, aquini@redhat.com,
	sergei.shtylyov@cogentembedded.com, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130527224149.GA4384@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/27/2013 03:41 PM, Francois Romieu wrote:
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

We should rate-limit these messages at least.  When a system is low on memory
the logs can quickly fill up with useless OOM messages, further slowing
the system...

Ben

>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
