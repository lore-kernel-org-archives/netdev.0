From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCHv2, 2/7] ppc: bpf/jit: Fix/enhance 32-bit Load Immediate implementation
Date: Tue, 28 Jun 2016 22:10:12 +1000 (AEST)
Message-ID: <3rf4Pc1S8mz9sXy@ozlabs.org>
References: <d584015e9fb33ed526d693c5ab3c228d385f3c74.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Matt Evans <matt@ozlabs.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@fb.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:49336 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbcF1MKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 08:10:13 -0400
In-Reply-To: <d584015e9fb33ed526d693c5ab3c228d385f3c74.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-22-06 at 16:25:02 UTC, "Naveen N. Rao" wrote:
> The existing LI32() macro can sometimes result in a sign-extended 32-bit
> load that does not clear the top 32-bits properly. As an example,
> loading 0x7fffffff results in the register containing
> 0xffffffff7fffffff. While this does not impact classic BPF JIT
> implementation (since that only uses the lower word for all operations),
> we would like to share this macro between classic BPF JIT and extended
> BPF JIT, wherein the entire 64-bit value in the register matters. Fix
> this by first doing a shifted LI followed by ORI.
> 
> An additional optimization is with loading values between -32768 to -1,
> where we now only need a single LI.
> 
> The new implementation now generates the same or less number of
> instructions.
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Series applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/aaf2f7e09932a08c1287d8e4c6

cheers
