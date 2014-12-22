From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [BUG] rtl8192se: panic accessing unmapped memory in skb
Date: Mon, 22 Dec 2014 11:43:38 -0600
Message-ID: <5498584A.6080204@lwfinger.net>
References: <20141221172516.GA12784@zzz> <5497516A.2020400@lwfinger.net> <20141221234714.GA30675@zzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141221234714.GA30675@zzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/21/2014 05:47 PM, Eric Biggers wrote:
> Hi,
>
> To get your patched version to work at all I had to update
> _rtl_pci_init_rx_ring() to account for new return value of
> _rtl_pci_init_one_rxdesc().  I will let you know if anything shows up in the
> kernel log, but I expect this is a highly sporadic problem.  The system has 4 GB
> of memory, and I used the 3.18 kernel for 10 days prior to the panic with no
> issues.  The panic occurred while upgrading system packages, so it's possible
> jhat the system was experiencing memory pressure.
>
> I upgraded from 3.17 to 3.18 on Dec 8, so I've actually only had since then to
> notice any bugs that may have been introduced since 3.17.
>
> It does appear there were changes made to pci.c between 3.17 and 3.18.  It
> appears the 3.17 code will drop the incoming packet if a new skb can't be
> allocated, whereas the 3.18 code assumes a new skb can always be allocated.  The
> 3.17 behavior seems more logical to me.  I don't know how either of these
> behaviors compare to other networking drivers, however.

Sorry about missing the necessary changes in the rest of the driver. That is 
what I get for only compile testing.

I reviewed the 3.17 => 3.18 changes and found the difference in the logic that 
you noticed, and I missed earlier. As a result, I need to push this change for 
3.19 with the notation for updating of 3.18. You have probably received this 
patch already. As it needs to be backported, I decided to forgo changing the 
return value of _rtl_pci_init_one_rxdesc(). That change should be made, but 
there is no emergency there.

Thanks,

Larry
