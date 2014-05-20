From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH 1/8] ixgbe: Out of line ixgbe_read/write_reg
Date: Tue, 20 May 2014 17:06:17 +0000
Message-ID: <14DF3A68-94EE-499E-9B67-635CAF0AD6C7@intel.com>
References: <1400276595-6965-1-git-send-email-andi@firstfloor.org>
 <1400276595-6965-2-git-send-email-andi@firstfloor.org>
 <7477F573-2AED-4D26-8D5F-DB80DFA7EDEF@intel.com>
 <20140519232531.GJ19657@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Andi Kleen <andi@firstfloor.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>
To: Andi Kleen <ak@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140519232531.GJ19657@tassilo.jf.intel.com>
Content-Language: en-US
Content-ID: <8023E5A59B8A704F82EC141D71755564@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On May 19, 2014, at 4:25 PM, Andi Kleen <ak@linux.intel.com> wrote:

> On Mon, May 19, 2014 at 10:00:52PM +0000, Rustad, Mark D wrote:
>> On May 16, 2014, at 2:43 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> 
>>> From: Andi Kleen <ak@linux.intel.com>
>>> 
>>> ixgbe_read_reg and ixgbe_write_reg are frequently called and are very big
>>> because they have complex error handling code.
>> 
>> Actually, this patch doesn't do anything to ixgbe_write_reg, which would almost certainly be very bad for performance, but instead changes ixgbe_write_reg64.
> 
> I doubt a few cycles around the write make a lot of difference for MMIO. MMIO is dominated
> by other things.
> 
>> The latter is not in a performance-sensitive path, but is only called from one site, so there is little reason to take it out-of-line.
> 
> True I moved the wrong one.
> 
> ixgbe_write_reg                                    3305  (0.00%)  8     409  
> 
> 
>> I already have a patch in queue to make ixgbe_read_reg out-of-line, because it does have a very costly memory footprint inline, as you have found.
> 
> Please move write_reg too.

I will take a look at moving most of them out-of-line. There are just a few in very hot paths that should remain inline.

-- 
Mark Rustad, Networking Division, Intel Corporation
