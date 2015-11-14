From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH V3 2/2] arm64: bpf: make BPF prologue and epilogue align
 with ARM64 AAPCS
Date: Fri, 13 Nov 2015 18:39:33 -0800
Message-ID: <CABg9mcvomep=M1As_Vj=XuTNk=jiGwXQqQWbjotMXP2csKX=Bg@mail.gmail.com>
References: <CABg9mct-hnEhvT6y9ZgCC8nMan5YbmByQa_ViUWzeea6ToqG4A@mail.gmail.com>
 <1447438197-31838-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linaro-kernel@lists.linaro.org, Daniel Borkmann <daniel@iogearbox.net>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>,
 Alexei Starovoitov <ast@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 Network Development <netdev@vger.kernel.org>, Xi Wang <xi.wang@gmail.com>
To: Yang Shi <yang.shi@linaro.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1447438197-31838-1-git-send-email-yang.shi@linaro.org>
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

Yang, I noticed another thing...

On Fri, Nov 13, 2015 at 10:09 AM, Yang Shi <yang.shi@linaro.org> wrote:
> Save and restore FP/LR in BPF prog prologue and epilogue, save SP to FP
> in prologue in order to get the correct stack backtrace.
>
> However, ARM64 JIT used FP (x29) as eBPF fp register, FP is subjected to
> change during function call so it may cause the BPF prog stack base address
> change too.
>
> Use x25 to replace FP as BPF stack base register (fp). Since x25 is callee
> saved register, so it will keep intact during function call.

Can you please add save/restore for x25 also? :)

> It is initialized in BPF prog prologue when BPF prog is started to run
> everytime. When BPF prog exits, it could be just tossed.
>
