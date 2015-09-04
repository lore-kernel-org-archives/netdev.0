From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: eBPF / seccomp globals?
Date: Fri, 4 Sep 2015 08:03:49 -0600
Message-ID: <20150904140349.GK26679@smitten>
References: <CAMkWEXPxrth6Bt1X1OhAQYMWPM5XSy2oJEtCkv1grLFNYo5Edg@mail.gmail.com>
 <20150904031704.GA1427@Alexeis-MBP-2.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tirado <mtirado418@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Kees Cook <keescook@chromium.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150904031704.GA1427@Alexeis-MBP-2.westell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On Thu, Sep 03, 2015 at 08:17:05PM -0700, Alexei Starovoitov wrote:
> On Fri, Sep 04, 2015 at 01:01:20AM +0000, Michael Tirado wrote:
> > Hiyall,
> > 
> > I have created a seccomp white list filter for a program that launches
> > other less trustworthy programs.  It's working great so far, but I
> > have run into a little roadblock.  the launcher program needs to call
> > execve as it's final step, but that may not be present in the white
> > list.  I am wondering if there is any way to use some sort of global
> > variable that will be preserved between syscall filter calls so that I
> > can allow only one execve, if not present in white list by
> > incrementing a counter variable.
> > 
> > I see that in Documentation/networking/filter.txt one of the registers
> > is documented as being a pointer to struct sk_buff, in the seccomp
> > context this is a pointer to struct seccomp_data  instead, right?  and
> > the line about callee saved registers R6-R9  probably refers to them
> > being saved across calls within that filter, and not calls between
> > filters?
> 
> R6-R9 are the registered preserved across calls to helper functions
> within single program. They are not preserved across invocations
> of the same program. At the start of the program only R1 (pointer
> to context) is valid.
> The eBPF programs used for kprobes, sockets and TC can simulate
> global state via maps. Like a map of one element can have some
> 'struct globals { ... }' as a value in such map. Then programs
> can keep global state in there. If a key into such map is cpu_id,
> then such state becomes per-cpu global. Other tricks possible too.
> Unfortunately seccomp doesn't have access to eBPF yet
> (only classic BPF is supported), but, I believe, Tycho is
> working on adding eBPF to seccomp and criu of eBPF programs...

Indeed I am, however my patches don't have support for seccomp
programs using eBPF maps. I'm intending to post them later today, so
stay tuned.

Tycho
