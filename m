From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH 00/14] arm64: eBPF JIT compiler
Date: Tue, 22 Jul 2014 22:24:13 -0700
Message-ID: <CABg9mcsPUwQe_7KrG=-8UJi1cA3+xbaDo1u+niFQ+JQRt37w7Q@mail.gmail.com>
References: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
	<20140721091623.GA16122@arm.com>
	<CAMEtUuyC+MykPDO0ghTc=oex7KPLEy=BLRgWBdW+qJY7JXQmDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Catalin Marinas <Catalin.Marinas@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyC+MykPDO0ghTc=oex7KPLEy=BLRgWBdW+qJY7JXQmDQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 21, 2014 at 8:49 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Mon, Jul 21, 2014 at 2:16 AM, Will Deacon <will.deacon@arm.com> wrote:
[...]
>>> This series applies against net-next and is tested working
>>> with lib/test_bpf on ARMv8 Foundation Model.
>>
>> Looks like it works on my Juno board too, so:
>>
>>   Acked-by: Will Deacon <will.deacon@arm.com>
>>
>> for the series.

Thanks Will! I've added your acked-by to the entire series, also
tweaked 14/14's commit log to indicate that it's been tested on Juno
as well.

>>
>> It's a bit late for 3.17 now, so I guess we'll queue this for 3.18 (which
>> also means the dependency on -next isn't an issue). Perhaps you could repost
>> around -rc3?
>
> Thanks for testing! Nice to see it working on real hw.
> I'm not sure why you're proposing a 4+ week delay. The patches
> will rot instead of getting used and tested. Imo it makes sense to
> get them into net-next now for 3.17.
> JIT is disabled by sysctl by default anyway.

Hmm... if net-next is still open, and David is willing to pull in this
series, I share Alexei's opinion -- don't see why a delay is
necessary. David, any chance of pulling this series into net-next for
3.17?

BTW, I also tried merging
'git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git
for-next/core' with this series. The example merge is available at
'https://github.com/zlim/linux.git arm64/bpf-merge'. The merge
conflict resolution is really trivial:
--------8<--------
diff --cc arch/arm64/Kconfig
index 7534a80a,ce6e733..c165c91
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@@ -32,8 -33,8 +34,9 @@@ config ARM6
        select HAVE_ARCH_JUMP_LABEL
        select HAVE_ARCH_KGDB
        select HAVE_ARCH_TRACEHOOK
-       select HAVE_C_RECORDMCOUNT
 +      select HAVE_BPF_JIT
+       select HAVE_C_RECORDMCOUNT
+       select HAVE_CC_STACKPROTECTOR
        select HAVE_DEBUG_BUGVERBOSE
        select HAVE_DEBUG_KMEMLEAK
        select HAVE_DMA_API_DEBUG
-------->8--------

Anyway, here's an updated branch (with Will's acks, commit log tweak
noting Will's testing on real hardware, rebase on net-next). I can
repost entire patch series if needed.

----------------------------------------------------------------
The following changes since commit 52c4f0ec662bbf02f1b0bcb311a48af2c8e5ee89:

  drivers: net: cpsw: add support to dump ALE table via ethtool
register dump (2014-07-22 19:58:25 -0700)

are available in the git repository at:

  https://github.com/zlim/linux.git arm64/bpf

for you to fetch changes up to 533f668ff3e8d69f22c6e5432e0eb1005f2e8970:

  arm64: eBPF JIT compiler (2014-07-22 21:52:09 -0700)

----------------------------------------------------------------
