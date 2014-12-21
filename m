From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [BUG] rtl8192se: panic accessing unmapped memory in skb
Date: Sun, 21 Dec 2014 17:47:14 -0600
Message-ID: <20141221234714.GA30675@zzz>
References: <20141221172516.GA12784@zzz>
 <5497516A.2020400@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5497516A.2020400@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

To get your patched version to work at all I had to update
_rtl_pci_init_rx_ring() to account for new return value of
_rtl_pci_init_one_rxdesc().  I will let you know if anything shows up in the
kernel log, but I expect this is a highly sporadic problem.  The system has 4 GB
of memory, and I used the 3.18 kernel for 10 days prior to the panic with no
issues.  The panic occurred while upgrading system packages, so it's possible
jhat the system was experiencing memory pressure.

I upgraded from 3.17 to 3.18 on Dec 8, so I've actually only had since then to
notice any bugs that may have been introduced since 3.17.

It does appear there were changes made to pci.c between 3.17 and 3.18.  It
appears the 3.17 code will drop the incoming packet if a new skb can't be
allocated, whereas the 3.18 code assumes a new skb can always be allocated.  The
3.17 behavior seems more logical to me.  I don't know how either of these
behaviors compare to other networking drivers, however.

Eric
