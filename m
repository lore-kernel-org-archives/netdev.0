From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH v2] i40e/i40evf: fix out-of-bounds read of cpumask
Date: Tue, 22 Aug 2017 21:48:40 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882A63183@ORSMSX115.amr.corp.intel.com>
References: <20170822210442.18006-1-jacob.e.keller@intel.com>
 <20170822232349.52b9ad06@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Intel Wired LAN <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        Juergen Gross <jgross@suse.com>
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170822232349.52b9ad06@elisabeth>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Stefano Brivio
> Sent: Tuesday, August 22, 2017 2:24 PM
> To: Keller, Jacob E <jacob.e.keller@intel.com>
> Cc: Intel Wired LAN <intel-wired-lan@lists.osuosl.org>; netdev@vger.kernel.org;
> stable@vger.kernel.org; Juergen Gross <jgross@suse.com>
> Subject: Re: [PATCH v2] i40e/i40evf: fix out-of-bounds read of cpumask
> 
> [Fixed Cc: address for stable, Cc'ed Juergen]
> 
> On Tue, 22 Aug 2017 14:04:42 -0700
> Jacob Keller <jacob.e.keller@intel.com> wrote:
> 
> > When responding to an affinity hint we directly copied a cpumask value,
> > intsead of using cpumask_copy. According to cpumask.h this is not
> > correct because cpumask_t is only guaranteed to have enough space for
> > the number of CPUs in the system, and may not be as big as we expect.
> > Thus a direct copy results in an out-of-bound read and potentially
> > a crash if the pages are aligned just right. This will be easily
> > detected on a kernel with KASAN enabled:
> 
> I still think commit message of my patch
> (ae9c9586f61e914dc1c6fe2e6ac1fb2bf07283bc.1502792828.git.sbrivio@redhat.co
> m)
> was perhaps a bit clearer, but okay, this is also clear, fair enough.
> 
> > KASAN reports:
> > [   25.242312] BUG: KASAN: slab-out-of-bounds in
> i40e_irq_affinity_notify+0x30/0x50 [i40e] at addr ffff880462eea960
> [...]
> > [   25.242597]
> ==================================================================
> 
> This is also taken from my message, not terribly happy about it
> (and still happier with it than without). Fair enough, whatever it
> takes to get this applied as soon as possible...
> 
> > Fixes: 96db776a3682 ("i40e/i40evf: fix interrupt affinity bug", 2016-09-14)
> > Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> > Cc: stable@vger.kernel.org # 4.10+
> 
> FWIW,
> 
> Acked-by: Stefano Brivio <sbrivio@redhat.com>
> 

I don't really care which message gets applied either, as long as we get it fixed. Either patch is fine with me.

Thanks,
Jake

> 
> --
> Stefano
