From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH 0/4] Add lightweight memory barriers fast_rmb() and fast_wmb()
Date: Tue, 18 Nov 2014 07:44:13 -0800
Message-ID: <546B694D.3080604@redhat.com>
References: <20141117171005.22333.96544.stgit@ahduyck-server> <063D6719AE5E284EB5DD2968C1650D6D1C9F2930@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>,
	"mingo@kernel.org" <mingo@kernel.org>,
	"mikey@neuling.org" <mikey@neuling.org>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"geert@linux-m68k.org" <geert@linux-m68k.org>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"michael@ellerman.id.au" <michael@ellerman.id.au>,
	"tony.luck@intel.com" <tony.luck@intel.com>,
	"torvalds@li
To: David Laight <David.Laight@ACULAB.COM>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9F2930@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 11/18/2014 01:57 AM, David Laight wrote:
> From: Alexander Duyck
>> These patches introduce two new primitives for synchronizing cache-enabled
>> memory writes and reads.  These two new primitives are:
>>
>> 	fast_rmb()
>> 	fast_wmb()
> Not sure I like the names.
> If the aim is to sync data into the local cache so that hardware
> that is doing cache-snooping accesses sees the data then maybe
> 	local_rmb() and local_wmb()

Yeah, that is the general consensus.  I am planning to change them to 
coherent_rmb() and coherent_wmb().

> IIRC read_barrier_depends() is a nop on everything except alpha.
> Maybe add the default if it isn't defined by the MD file?
>
> 	David
>   

 From my patch the only two I saw define it were alpha and blackfin. It 
is already defined in asm-generic, the rest is just clean-up since I 
suspect some of the arch tree barrier.h calls just borrowed from 
asm-generic without sorting out what became redundancies.

Thanks,

Alex
