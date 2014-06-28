From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and
 BPF maps
Date: Fri, 27 Jun 2014 22:55:15 -0700
Message-ID: <CAMEtUuzWs+MbSOGGD-Rc01DHKASa4GxbHdtCrSCLit4cUM35mA@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-4-git-send-email-ast@plumgrid.com>
	<CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
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
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2014 at 5:16 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Jun 27, 2014 at 5:05 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> BPF syscall is a demux for different BPF releated commands.
>>
>> 'maps' is a generic storage of different types for sharing data between kernel
>> and userspace.
>>
>> The maps can be created/deleted from user space via BPF syscall:
>> - create a map with given id, type and attributes
>>   map_id = bpf_map_create(int map_id, map_type, struct nlattr *attr, int len)
>>   returns positive map id or negative error
>>
>> - delete map with given map id
>>   err = bpf_map_delete(int map_id)
>>   returns zero or negative error
>
> What's the scope of "id"?  How is it secured?

the map and program id space is global and it's cap_sys_admin only.
There is no pressing need to do it with per-user limits.
So the whole thing is root only for now.

Since I got your attention please review the most interesting
verifier bits (patch 08/14) ;)
