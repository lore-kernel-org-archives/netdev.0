From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 1/6] filter: refactor BPF JIT for seccomp
 filters
Date: Fri, 26 Apr 2013 08:20:36 -0700
Message-ID: <1366989636.8964.214.camel@edumazet-glaptop>
References: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
	 <1366962706-24204-2-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366962706-24204-2-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-04-26 at 03:51 -0400, Xi Wang wrote:
> Currently, bpf_jit_compile() and bpf_jit_free() takes an sk_filter,
> which seccomp filters cannot reuse.
>=20
> Change bpf_jit_compile() to take a pointer to BPF instructions and
> the length, and to return a JITted function.
>=20
> Change bpf_jit_free() to take a JITted function.
>=20
> Add JIT calls for seccomp filters.
>=20
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> ---

When submitting a patch serie, full kernel must be fully compile-able
after each patch.

Thats mandatory to be able to perform git bisection in the future.

You cannot change the prototypes as you do in this patch, because it
breaks all the BPF JIT.

arch/x86/net/bpf_jit_comp.c:147:6: error: conflicting types for =E2=80=98=
bpf_jit_compile=E2=80=99
include/linux/filter.h:57:19: note: previous declaration of =E2=80=98bp=
f_jit_compile=E2=80=99 was here
arch/x86/net/bpf_jit_comp.c:749:6: error: conflicting types for =E2=80=98=
bpf_jit_free=E2=80=99
include/linux/filter.h:58:13: note: previous declaration of =E2=80=98bp=
f_jit_free=E2=80=99 was here
make[1]: *** [arch/x86/net/bpf_jit_comp.o] Error 1
make: *** [arch/x86/net/bpf_jit_comp.o] Error 2
