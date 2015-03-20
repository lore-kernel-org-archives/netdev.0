From: Michal Sekletar <msekleta@redhat.com>
Subject: Re: [PATCH net-next v2] filter: introduce SKF_AD_VLAN_TPID BPF
 extension
Date: Fri, 20 Mar 2015 11:27:18 +0100
Message-ID: <20150320102718.GB30812@morgoth.brq.redhat.com>
References: <1426763414-10091-1-git-send-email-msekleta@redhat.com>
 <550AF483.8040202@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jpirko@redhat.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53435 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426AbbCTK1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 06:27:50 -0400
Content-Disposition: inline
In-Reply-To: <550AF483.8040202@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 09:08:35AM -0700, Alexei Starovoitov wrote:
> On 3/19/15 4:10 AM, Michal Sekletar wrote:
> >If vlan offloading takes place then vlan header is removed from frame
> >and its contents, both vlan_tci and vlan_proto, is available to userspace via
> >TPACKET interface. However, only vlan_tci can be used in BPF filters.
> >
> >This commit introduces new BPF extension. It makes possible to load value of
> >vlan_proto (vlan TPID) to register A.
> 
> Agree with the idea, though we need to decide whether to do ntohs on
> vlan_proto or not. Since right now your patch makes it consistent
> on different architectures.
> 
> For arch where extended BPF jit is available the following:
> > +	case SKF_AD_OFF + SKF_AD_VLAN_TPID:
> ...
> > +		/* A = ntohs(A) [emitting a nop or swap16] */
> > +		*insn = BPF_ENDIAN(BPF_FROM_BE, BPF_REG_A, 16);
> 
> will make sure that it's doing ntohs,
> whereas arm JIT is doing normal 16-bit load.
> ppc can be both big and little, so PPC_LHZ_OFFS is incorrect.
> 
> Since it's a new field, I think it makes sense not to do ntohs at all.
> Let bpf programs do htons(PROTO_CONSTANT), since it can be done at
> compile time instead of run-time.

Doing htons is not needed for vlan_tci thus I wanted to avoid surprise for
users. But of course I'll do whatever you think is the best.

Also in v3 I will leave out all the jit bits. Once non-jit bits are merged then
I will be sending separate patches for the rest.

Hope that makes sense,

Michal

> 
