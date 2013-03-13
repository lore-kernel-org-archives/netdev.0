From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-next 05/22] cxgb4: Add T5 write combining support
Date: Wed, 13 Mar 2013 15:54:45 -0700
Message-ID: <514103B5.7040002@chelsio.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com> <1363088794-31453-6-git-send-email-vipul@chelsio.com> <20130312.081927.1036246728528667686.davem@davemloft.net> <513F3EBD.5020504@opengridcomputing.com> <51408ED4.40400@chelsio.com> <AE90C24D6B3A694183C094C60CF0A2F6026B718B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vipul Pandya <vipul@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
	roland@purestorage.com, JBottomley@parallels.com,
	Dimitrios Michailidis <dm@chelsio.com>,
	Naresh Kumar Inna <naresh@chelsio.com>,
	Divy Le Ray <divy@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Arvind Bhushan <arvindb@chelsio.com>,
	Abhishek Agrawal <abhishek@chelsio.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B718B@saturn3.aculab.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 03/13/13 08:43, David Laight wrote:
> From my recollection of the x86 architecture, the memory barriers are 
> hardly ever needed, certainly not in the places where, for example a 
> ppc needs them. I'd actually suspect that the normal wmb() for x86 
> should be a nop. About the only place where any on the fence 
> instructions are needed are in relation to write combining accesses. 
> In particular I don't believe they are ever needed to synchronise 
> uncached accesses with each other, or with cached accesses (which are 
> snooped). David 

   The question at hand is how should we indicate that we're finished 
with a Write Combined set of stores in an architecturally neutral 
manner?  Is wmb() a good approach?  Vipul has noted that the iWarp code 
uses a new "wc_wmb()" for this purpose which seems to be the same 
_currently_ as wmb() for all current platforms.  I presume that the 
iWarp folks pick a new name to offer themselves some cover in the future.

   And yes, the code sequence that was accidentally included in Vipul's 
previous patches should never have been submitted for inclusion in 
kernel.org.  It got missed in our internal reviews and I apologize for that.

Casey
