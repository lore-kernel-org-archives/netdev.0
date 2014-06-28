From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC net-next 07/14] bpf: expand BPF syscall with program load/unload
Date: Sat, 28 Jun 2014 08:35:51 -0700
Message-ID: <CALCETrUs8mmVK70rwkQz=Dzu2ZjPYU_TMuydnXsJM8jAxTv0WQ@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
 <1403913966-4927-8-git-send-email-ast@plumgrid.com> <CALCETrXDR1LVmbigTicBiddgvcucM1dGk1R7rxdJyBCvGEBQMw@mail.gmail.com>
 <CAMEtUuywNHVcZ__296NzXK7RPXUBOf7gNQY9JFx0a9PV0Se+wA@mail.gmail.com>
 <CALCETrXQ60J+UqafHRKPbgQ37zhstW+E8xAponWs7AQ-DCgaWA@mail.gmail.com>
 <CAMEtUuwmxgrGMigmh1vZ7qCh9qB9ph9uFbPmVmmbqZvC5N9WyA@mail.gmail.com> <20140628152104.GB29548@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140628152104.GB29548@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 28, 2014 at 8:21 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Sat, Jun 28, 2014 at 12:26:14AM -0700, Alexei Starovoitov wrote:
>> On Fri, Jun 27, 2014 at 11:28 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> > On Fri, Jun 27, 2014 at 11:12 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> > If you want to add GPL-only functions in the future, that would be one
>> > thing.  But if someone writes a nice eBPF compiler, and someone else
>> > writes a little program that filters on network packets, I see no
>> > reason to claim that the little program is a derivative work of the
>> > kernel and therefore must be GPL.
>>
>> I think we have to draw a line somewhere. Say, tomorrow I want
>> to modify libpcap to emit eBPF based on existing tcpdump syntax.
>> Would it mean that tcpdump filter strings are GPLed? Definitely not,
>> since they existed before and can function without new libpcap.
>> But if I write a new packet filtering program in C, compile it
>> using LLVM->eBPF and call into in-kernel helper functions
>> (like bpf_map_lookup_elem()),  I think it's exactly the derivative work.
>> It's analogous to kernel modules. If module wants to call
>> export_symbol_gpl() functions, it needs to be GPLed. Here all helper
>> functions are GPL. So we just have a blank check for eBPF program.
>
> I agree, these eBFP programs should be GPL-compatible licensed as well.

I think I'd be happy with an export_symbol_gpl analogue.  I might
argue that bpf_map_lookup_elem shouldn't be gpl-only, though.
Something like "look up the uid that opened a port," on the other
hand, maybe should be.

--Andy
