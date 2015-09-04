From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Fri, 4 Sep 2015 14:08:37 -0700
Message-ID: <CAGXu5jKGBuD15KBfXKoYbGB40cNsbh=Dz8GM=bmUL-oECRhzxA@mail.gmail.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
	<1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
	<CAGXu5j+9YvL6XzX=x8krZbdJXFpe-3FuMu=hAZX9Ew=hYyuK7Q@mail.gmail.com>
	<20150904210615.GR26679@smitten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150904210615.GR26679@smitten>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 4, 2015 at 2:06 PM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> On Fri, Sep 04, 2015 at 01:34:12PM -0700, Kees Cook wrote:
>> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
>> <tycho.andersen@canonical.com> wrote:
>> > +static const struct bpf_func_proto *
>> > +seccomp_func_proto(enum bpf_func_id func_id)
>> > +{
>> > +       /* Right now seccomp eBPF loading doesn't support maps; seccomp filters
>> > +        * are considered to be read-only after they're installed, so map fds
>> > +        * probably need to be invalidated when a seccomp filter with maps is
>> > +        * installed.
>> > +        *
>> > +        * The rest of these might be reasonable to call from seccomp, so we
>> > +        * export them.
>> > +        */
>> > +       switch (func_id) {
>> > +       case BPF_FUNC_ktime_get_ns:
>> > +               return &bpf_ktime_get_ns_proto;
>> > +       case BPF_FUNC_trace_printk:
>> > +               return bpf_get_trace_printk_proto();
>> > +       case BPF_FUNC_get_prandom_u32:
>> > +               return &bpf_get_prandom_u32_proto;
>> > +       case BPF_FUNC_get_smp_processor_id:
>> > +               return &bpf_get_smp_processor_id_proto;
>> > +       case BPF_FUNC_tail_call:
>> > +               return &bpf_tail_call_proto;
>> > +       case BPF_FUNC_get_current_pid_tgid:
>> > +               return &bpf_get_current_pid_tgid_proto;
>> > +       case BPF_FUNC_get_current_uid_gid:
>> > +               return &bpf_get_current_uid_gid_proto;
>> > +       case BPF_FUNC_get_current_comm:
>> > +               return &bpf_get_current_comm_proto;
>> > +       default:
>> > +               return NULL;
>> > +       }
>> > +}
>>
>> While this list is probably fine, I don't want to mix the addition of
>> eBPF functions to the seccomp ABI with the CRIU changes. No function
>> calls are currently possible and it should stay that way.
>
> Ok, I can remove them.
>
>> I was expecting to see a validator, similar to the existing BPF
>> validator that is called when creating seccomp filters currently. Can
>> we add a similar validator for new BPF_PROG_TYPE_SECCOMP?
>
> That's effectively what this patch does; when the eBPF is loaded via
> bpf(), you tell bpf() you want a BPF_PROG_TYPE_SECCOMP, and it invokes
> this validation/translation code, i.e. it uses
> seccomp_is_valid_access() to check and make sure access are aligned
> and inside struct seccomp_data.

What about limiting the possible instructions?

-Kees

-- 
Kees Cook
Chrome OS Security
