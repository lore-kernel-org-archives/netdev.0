From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 23/33] x86/asm/bpf: Create stack frames in bpf_jit.S
Date: Fri, 22 Jan 2016 08:36:38 +0100
Message-ID: <20160122073638.GA28042@gmail.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <fa4c41976b438b51954cb8021f06bceb1d1d66cc.1453405861.git.jpoimboe@redhat.com>
 <20160122024427.GA6000@ast-mbp.thefacebook.com>
 <20160122035531.GA20502@treble.redhat.com>
 <20160122041845.GA7175@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Poimboeuf <jpoimboe@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35467 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbcAVHgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 02:36:44 -0500
Content-Disposition: inline
In-Reply-To: <20160122041845.GA7175@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> > > I could be missing something. I think either this patch is not need or you 
> > > need to teach the tool to ignore all JITed stuff. I don't think it's 
> > > practical to annotate everything. Different JITs do their own magic. s390 
> > > JIT is even more fancy.
> > 
> > Well, but the point of these patches isn't to make the tool happy.  It's 
> > really to make sure that runtime stack traces can be made reliable. Maybe I'm 
> > missing something but I don't see why JIT code can't honor 
> > CONFIG_FRAME_POINTER just like any other code.
> 
> It can if there is no performance cost added. I can speak for x64 JIT, but the 
> rest needs to be analyzed as well. My point was that may be it's easier to 
> ignore all JITed code and just say that such call stacks may be unreliable? 
> live-patching is not applicable to JITed code anyway or you want to livepatch 
> the callees of it?

So the rule is that if frame pointers are enabled all kernel code should have 
correct stack frames - in case an IRQ (or NMI) hits it or it crashes.

Thanks,

	Ingo
