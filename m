From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] Add -target to clang switches while cross compiling.
Date: Thu, 12 Oct 2017 16:16:17 -0700
Message-ID: <20171012231615.ugya5fa4mvrze6hw@ast-mbp>
References: <1507841157-10487-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
 <20171012222302.3zlndmcm7ixywbs6@ast-mbp>
 <20171012224322.GA7007@abhijit-ayarekar.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>,
        ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, yhs@fb.com
To: Abhijit Ayarekar <abhijit.ayarekar@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171012224322.GA7007@abhijit-ayarekar.cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 03:43:22PM -0700, Abhijit Ayarekar wrote:
> On Thu, Oct 12, 2017 at 03:23:04PM -0700, Alexei Starovoitov wrote:
> > On Thu, Oct 12, 2017 at 01:45:57PM -0700, Abhijit Ayarekar wrote:
> > > Latest llvm update excludes assembly instructions.
> > > As a result __ASM_SYSREGS_H define is not required.
> > > -target switch includes appropriate target specific files.
> > > 
> > > Tested on x86 and arm64 with llvm with git revision
> > > commit df6ca162269f9d756f8742bf4b658dcf690e3eb5
> > > Author: Yonghong Song <yhs@fb.com>
> > > Date:   Thu Sep 28 02:46:11 2017 +0000
> > > 
> > >     bpf: add new insns for bswap_to_le and negation
> > > 
> > > Signed-off-by: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>
> > > ---
> > >  samples/bpf/Makefile | 5 +++--
> > >  1 file changed, 3 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> > > index ebc2ad6..81f9fcd 100644
> > > --- a/samples/bpf/Makefile
> > > +++ b/samples/bpf/Makefile
> > > @@ -180,6 +180,7 @@ CLANG ?= clang
> > >  # Detect that we're cross compiling and use the cross compiler
> > >  ifdef CROSS_COMPILE
> > >  HOSTCC = $(CROSS_COMPILE)gcc
> > > +CLANG_ARCH_ARGS = -target $(ARCH)
> > 
> > this is only need because you're crosscompiling, right?
> Yes
> 
> > In native compilation it's unnecessary flag.
> > Only droping -D__ASM_SYSREG_H is enough, correct?
> > 
> Yes. That is correct.

please update commit log then and reference proper llvm commit
that added asm support instead of 'add new insns for bswap_to_le'
which is unrelated.
