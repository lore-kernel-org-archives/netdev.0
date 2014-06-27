From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2 2/2] powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT
 test
Date: Fri, 27 Jun 2014 15:08:17 +1000
Message-ID: <1403845697.21873.1.camel@concordia>
References: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
	  <1403717697-3911-2-git-send-email-kda@linux-powerpc.org>
	 <1403771455.18572.8.camel@concordia> <53ABDB72.9020902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:53143 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbaF0FI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2014 01:08:27 -0400
In-Reply-To: <53ABDB72.9020902@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-26 at 10:36 +0200, Daniel Borkmann wrote:
> On 06/26/2014 10:30 AM, Michael Ellerman wrote:
> > On Wed, 2014-06-25 at 21:34 +0400, Denis Kirjanov wrote:
> >> We have to return the boolean here if the tag presents
> >> or not, not just ANDing the TCI with the mask which results to:
> >>
> >> [  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
> >> [  709.412245] ret 4096 != 1
> >> [  709.412332] ret 4096 != 1
> >> [  709.412333] FAIL (2 times)
> >
> > Hi Denis,
> >
> > Is this the same version of test_bpf that is in Linus' tree?
> >
> > I don't see any fails with that version, am I missing something?
> >
> >    [  187.690640] test_bpf: #18 LD_VLAN_TAG_PRESENT 46 50 PASS
> 
> Did you try to modprobe test_bpf after enabling JIT, i.e. :
> 
>    echo 1 > /proc/sys/net/core/bpf_jit_enable
> 
> Last time I tested with ppc64, I saw the interpreter passing
> while JIT failed, which the fix above should address.

Right, I thought CONFIG_BPF_JIT=y was sufficient.

But that just makes it available, I need to *also* enable it at runtime.

cheers
