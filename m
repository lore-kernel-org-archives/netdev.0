From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v12 net-next 03/11] bpf: add lookup/update/delete/iterate
 methods to BPF maps
Date: Tue, 16 Sep 2014 14:23:27 -0700
Message-ID: <CAMEtUuzy0Hvjr0f4XBrH+FAxaKD7aijnYzDe3-MPrGWe6+MD4Q@mail.gmail.com>
References: <1410808721-27493-4-git-send-email-ast@plumgrid.com>
	<20140916.151606.448751391205382097.davem@davemloft.net>
	<CAMEtUuxp6709mdygiQyCqwjv-0kF-CbNOzCCZmKw_mUckF4NZA@mail.gmail.com>
	<20140916.165452.1747695341192703967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140916.165452.1747695341192703967.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 16, 2014 at 1:54 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>
> The cost of the compat layer must be considered and weighted
> against this cast, which I think is really no big deal.
>
>> I think compat layer is a better option.
>
> It's overhead you'll have to support forever, I think you should
> reconsider.
>
> All of the "ugly casting" will be hidden, or can be hidden, in the
> syscall wrappers and/or interfaces in userspace.

ahh, ok. I thought you're strongly against any type of casts.
In such case I can get rid of 'union bpf_attr' as well and simply
define a struct per command, then syscall will look like:
sys_bpf(int cmd, void __user *attr, unsigned int size);
and uapi/linux/bpf.h will have:
struct bpf_prog_load_attr { /* for BPF_PROG_LOAD cmd */
    __u32 prog_type;
    __u32 insn_cnt;
    __aligned_u64 insns;
    __aligned_u64 license;
    __u32 log_level;
    __u32 log_size;
    __aligned_u64 log_buf;
};
and similar for other commands.
no compat layer and type checking will be done
by syscall wrappers. Ok?
