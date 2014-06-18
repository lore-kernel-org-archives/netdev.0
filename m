From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: MIPS: Add MSI support for XLP9XX
Date: Wed, 18 Jun 2014 09:00:08 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725E5A8@AcuExch.aculab.com>
References: <20140610013104.DF5A8660F61@gitolite.kernel.org>
 <20140618001837.GA24753@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ganesanr@broadcom.com" <ganesanr@broadcom.com>
To: 'Dave Jones' <davej@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140618001837.GA24753@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones
> On Tue, Jun 10, 2014 at 01:31:04AM +0000, Linux Kernel wrote:
>  > Gitweb:     http://git.kernel.org/linus/;a=commit;h=d66f3f0e10b49df8d0cc0d8eb5bf2ef9863a33cf
>  > Commit:     d66f3f0e10b49df8d0cc0d8eb5bf2ef9863a33cf
>  > Parent:     1c98398662c9b4e2f03f64344f83dd6cb14e0420
>  > Refname:    refs/heads/master
>  > Author:     Ganesan Ramalingam <ganesanr@broadcom.com>
>  > AuthorDate: Fri May 9 16:35:49 2014 +0530
>  > Committer:  Ralf Baechle <ralf@linux-mips.org>
>  > CommitDate: Fri May 30 16:51:02 2014 +0200
>  >
>  >     MIPS: Add MSI support for XLP9XX
> 
> ...
> 
>  > +		if (cpu_is_xlp9xx()) {
>  > +			val = ((node * nlm_threads_per_node()) << 7 |
>  > +				PIC_PCIE_MSIX_IRQ(link) << 1 | 0 << 0);
> 
> Should this be..
> 
> 			val = ((node * nlm_threads_per_node()) << 7 |
> 				PIC_PCIE_MSIX_IRQ(link) << 1);
> 			val &= ~(1 << 0);
> 
> perhaps ? because shifting a zero is a nop, as is ORing it.

Unlikely, it looks to me as though it is just being explicit that the
low bit of the compound word (whatever it is) is zero.

	David
