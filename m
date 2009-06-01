From: Nix <nix@esperi.org.uk>
Subject: Re: 2.6.30rc7: ksoftirqd CPU saturation (x86-64 only,
	not x86-32) (e1000e-related?)
Date: Mon, 01 Jun 2009 20:33:43 +0100
Message-ID: <87d49nzr3c.fsf@hades.wkstn.nix>
References: <87prdozxns.fsf@hades.wkstn.nix>
	<alpine.WNT.1.10.0906010941170.656@jbrandeb-MOBL1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.WNT.1.10.0906010941170.656@jbrandeb-MOBL1.amr.corp.intel.com>
	(Jesse Brandeburg's message of "Mon,
	1 Jun 2009 09:48:18 -0700 (Pacific Daylight Time)")
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 1 Jun 2009, Jesse Brandeburg spake thusly:
>>  57:      0     0       0   7654      0      0      0     0   PCI-MSI-edge      gordianet-rx-0
>>  58:      0     0       0      0   8065      0      0     0   PCI-MSI-edge      gordianet-tx-0
>>  59:      0     0       0      0      3      0      0     0   PCI-MSI-edge      gordianet
>>  60:      0     0       0      0      0   3576      0     0   PCI-MSI-edge      fastnet-rx-0
>>  61:      0     0       0      0      0   2555      0     0   PCI-MSI-edge      fastnet-tx-0
>>  62:      0     0       0      0      0      0      2     0   PCI-MSI-edge      fastnet
>
> where is the e1000e interrupt here?  I was expecting to see eth0/eth1

Sorry, I renamed the interfaces and forgot because I've been running
with them renamed for so very long that I've forgotten that they ever
had other names!

They're the interrupts left in above. Not exactly line saturation, is
it?

>> I'd not expect that level of e1000e interrupt activity to flood the
>> ksoftirqds like this, and in 32-bit mode it doesn't.
>> 
>> So, anyone know what's going on, or how I could find out?
>
> when you went into 64 bit mode your kernel enabled the IOMMU/DMAR, which 
> means that map/unmap cycles are taking many more cycles per packet, 

I thought that might be so, but now I'm running in 64-bit mode with a
load of pretty much zero and the out-of-tree driver: and we see
ksoftirqd saturation with the in-tree driver on a completely idle box
(well, it's sending the odd packet out of the network interfaces because
it's headless and that's the only way I can see anything at all).

(actually I thought IOMMUs were supposed to *decrease* the load of
things like that. Is it because pte changes have to be propagated to the
IOMMU or something? It would be nice if the configure help text gave the
poor user some clue whether to turn it off or on. Presumably it's
sometimes useful or it wouldn't be there...)

> accounting for the increased CPU utilization.  you can disable at boot 
> with intel_iommu=off to see if it goes back to previous behavior.

Not so, it goes wrong in 32-bit mode as well: my original report was
incorrect, triggered by a faulty build (where 'faulty' equals
'accidentally used the in-tree e1000e rather than the out-of-tree one').

Will try hunting backwards (unisecting?) to see if the in-tree driver
*ever* worked with this card.

------------------------------------------------------------------------------
OpenSolaris 2009.06 is a cutting edge operating system for enterprises 
looking to deploy the next generation of Solaris that includes the latest 
innovations from Sun and the OpenSource community. Download a copy and 
enjoy capabilities such as Networking, Storage and Virtualization. 
Go to: http://p.sf.net/sfu/opensolaris-get
