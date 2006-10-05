From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: 2.6.18-mm3 oops in xfrm_register_mode
Date: Thu, 05 Oct 2006 08:06:51 -0700
Message-ID: <1160060811.9569.40.camel@dyn9047017100.beaverton.ibm.com>
References: <20061003001115.e898b8cb.akpm@osdl.org>
	 <4523CFEF.6000007@us.ibm.com>  <20061004095703.5c843514.akpm@osdl.org>
	 <1159995731.28106.82.camel@flooterbu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751482AbWJEPHV@vger.kernel.org>
To: Steve Fox <drfickle@us.ibm.com>
In-Reply-To: <1159995731.28106.82.camel@flooterbu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 16:02 -0500, Steve Fox wrote:
> On Wed, 2006-10-04 at 09:57 -0700, Andrew Morton wrote:
> 
> > You might well find this bisection lands you on origin.patch.  ie: a
> > mainline bug.  I note that David merged a few more xfrm fixes this morning.
> > 
> > So to confirm that, first test just origin.patch and if that fails, test
> > git-of-the-moment.  If that doesn't fail, they fixed it.
> 
> origin.patch from --m3 failed. Unfortunately so did a fresh clone of
> Linus's git tree.
> 

I am not an expert in that area, but your stack trace made me curious.
Looking at the dis-assembly, line of code in question is:

	        if (likely(modemap[mode->encap] == NULL)) {

Register contents indicate that, its called as

	xfrm_register_mode(&xfrm4_tunnel_mode, AF_INET);
or
	xfrm_register_mode(&xfrm4_transport_mode, AF_INET);

(family is AF_INET).

The invalid deref is due to modemap = 0x7ff (RAX: 00000000000007ff)

Since its so easy to reproduce, can you add a printk before
this check to dump mode->encap and modemap, afinfo, family etc ?
Just curious ..


Thanks,
Badari
