From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 0/4] Seccomp filter JIT support on ARM.
Date: Wed, 29 Apr 2015 09:46:14 -0700
Message-ID: <20150429164607.GA12410@Alexeis-MBP.westell.com>
References: <1430314657-2552-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Russell King <linux@arm.linux.org.uk>, Kees Cook <keescook@chromium.org>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>, Daniel Borkmann <dborkman@redhat.com>,
 Will Drewry <wad@chromium.org>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Nicolas Schichan <nschichan@freebox.fr>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1430314657-2552-1-git-send-email-nschichan@freebox.fr>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 29, 2015 at 03:37:33PM +0200, Nicolas Schichan wrote:
> Greetings,
> 
> The following patches allow the use of the existing JIT code under
> arch/arm for seccomp filters.
> 
> The first patch makes bpf_migrate_filter() available so that seccomp
> code can use it.
> 
> The second patch invokes the classic BPF JIT code and if this fails
> reverts to the internal BPF. The open coded double call to
> bpf_convert_filter() and bpf_prog_select_runtime() is replaced by
> bpf_migrate_filter()
> 
> The third patch adds support for loads from the seccomp_data structure in
> the ARM BPF JIT code.

the patches 1,2,3 look fine.

> The fourth and final patch fixes a bug in the emit_udiv() function
> when used to convert a BPF_ALU | BPF_DIV | BPF_K instruction in the
> ARM BPF JIT code.

this one looks independent from first three and probably should
be sent to stable?

Your cc list is different for every patch, why? What tree are you
thinking to go through? 1st patch is trivial, but 2nd belongs in
seccomp, 3rd and 4th are in arm32... I'd would say arm tree if Kees
is ok with it.
