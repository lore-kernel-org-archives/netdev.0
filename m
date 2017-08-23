From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v2 net-next 1/5] selftests/bpf: add a test
 for a bug in liveness-based pruning
Date: Wed, 23 Aug 2017 07:43:04 -0700
Message-ID: <a77f72bd-1134-e808-fa76-b3d24a160b3c@fb.com>
References: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com>
	<83dbbb0c-3cbc-e033-0ceb-f31db6eb57c2@solarflare.com>
Reply-To: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei
	Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann
	<daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <83dbbb0c-3cbc-e033-0ceb-f31db6eb57c2-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 8/23/17 7:09 AM, Edward Cree wrote:
> Writes in straight-line code should not prevent reads from propagating
>  along jumps.  With current verifier code, the jump from 3 to 5 does not
>  add a read mark on 3:R0 (because 5:R0 has a write mark), meaning that
>  the jump from 1 to 3 gets pruned as safe even though R0 is NOT_INIT.
>
> Verifier output:
> 0: (61) r2 = *(u32 *)(r1 +0)
> 1: (35) if r2 >= 0x0 goto pc+1
>  R1=ctx(id=0,off=0,imm=0) R2=inv(id=0,umax_value=4294967295,var_off=(0x0; 0xffffffff)) R10=fp0
> 2: (b7) r0 = 0
> 3: (35) if r2 >= 0x0 goto pc+1
>  R0=inv0 R1=ctx(id=0,off=0,imm=0) R2=inv(id=0,umax_value=4294967295,var_off=(0x0; 0xffffffff)) R10=fp0
> 4: (b7) r0 = 0
> 5: (95) exit
>
> from 3 to 5: safe
>
> from 1 to 3: safe
> processed 8 insns, stack depth 0
>
> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>

Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
