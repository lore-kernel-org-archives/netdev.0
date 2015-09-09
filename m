From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Wed, 09 Sep 2015 18:13:57 +0200
Message-ID: <55F05AC5.4000005@iogearbox.net>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com> <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com> <CALCETrVhmBS+uEjYwCE=CzkXL5C+mysj=Rq=jMD3LTqbZUDD-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>,
	Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrVhmBS+uEjYwCE=CzkXL5C+mysj=Rq=jMD3LTqbZUDD-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/04/2015 11:50 PM, Andy Lutomirski wrote:
> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
[...]
>> +static const struct bpf_func_proto *
>> +seccomp_func_proto(enum bpf_func_id func_id)
>> +{
>> +       /* Right now seccomp eBPF loading doesn't support maps; seccomp filters
>> +        * are considered to be read-only after they're installed, so map fds
>> +        * probably need to be invalidated when a seccomp filter with maps is
>> +        * installed.
>> +        *
>> +        * The rest of these might be reasonable to call from seccomp, so we
>> +        * export them.
>> +        */
>> +       switch (func_id) {
>> +       case BPF_FUNC_ktime_get_ns:
>> +               return &bpf_ktime_get_ns_proto;
>> +       case BPF_FUNC_trace_printk:
>> +               return bpf_get_trace_printk_proto();
>> +       case BPF_FUNC_get_prandom_u32:
>> +               return &bpf_get_prandom_u32_proto;
>
> I don't think we should expose prandom to unprivileged userspace.
> This may be an attack vector.

Agreed, it should not be exposed for unpriv'ed users.
