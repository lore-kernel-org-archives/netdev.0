From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v5 3/9] net: xfrm: use __this_cpu_read per-cpu helper
Date: Wed, 14 Nov 2012 09:43:55 +0100
Message-ID: <20121114084355.GK22290@secunet.com>
References: <50A1A7C9.3060703@gmail.com>
 <20121113072101.GG22290@secunet.com>
 <50A213DF.1040103@gmail.com>
 <20121113104839.GJ22290@secunet.com>
 <50A23EB0.1060808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <50A23EB0.1060808@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2012 at 08:36:00PM +0800, Shan Wei wrote:
> Steffen Klassert said, at 2012/11/13 18:48:
> >=20
> > Ok, so please add a commit message to describe your changes.
> >=20
> > Thanks.
> >=20
>=20
> [PATCH v5] net: xfrm: use __this_cpu_read per-cpu helper
>=20
> this_cpu_ptr/this_cpu_read is faster than per_cpu_ptr(p, smp_processo=
r_id())=20
> and can reduce  memory accesses.
> The latter helper needs to find the offset for current cpu,
> and needs more assembler instructions which objdump shows in followin=
g.=20
>=20
> this_cpu_ptr relocates and address. this_cpu_read() relocates the add=
ress
> and performs the fetch. this_cpu_read() saves you more instructions
> since it can do the relocation and the fetch in one instruction.
>=20
> per_cpu_ptr(p, smp_processor_id())=EF=BC=9A
>   1e:   65 8b 04 25 00 00 00 00         mov    %gs:0x0,%eax
>   26:   48 98                           cltq
>   28:   31 f6                           xor    %esi,%esi
>   2a:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi
>   31:   48 8b 04 c5 00 00 00 00         mov    0x0(,%rax,8),%rax
>   39:   c7 44 10 04 14 00 00 00         movl   $0x14,0x4(%rax,%rdx,1)
>=20
> this_cpu_ptr(p)
>   1e:   65 48 03 14 25 00 00 00 00      add    %gs:0x0,%rdx
>   27:   31 f6                           xor    %esi,%esi
>   29:   c7 42 04 14 00 00 00            movl   $0x14,0x4(%rdx)
>   30:   48 c7 c7 00 00 00 00            mov    $0x0,%rdi
>=20
> Signed-off-by: Shan Wei <davidshan@tencent.com>

Applied to ipsec-next, thanks!
