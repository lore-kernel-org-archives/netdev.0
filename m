From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v12 net-next 03/11] bpf: add
 lookup/update/delete/iterate methods to BPF maps
Date: Tue, 16 Sep 2014 16:54:52 -0400 (EDT)
Message-ID: <20140916.165452.1747695341192703967.davem@davemloft.net>
References: <1410808721-27493-4-git-send-email-ast@plumgrid.com>
	<20140916.151606.448751391205382097.davem@davemloft.net>
	<CAMEtUuxp6709mdygiQyCqwjv-0kF-CbNOzCCZmKw_mUckF4NZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuxp6709mdygiQyCqwjv-0kF-CbNOzCCZmKw_mUckF4NZA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Tue, 16 Sep 2014 13:44:12 -0700

> the union indeed changes alignment from patch #1 to #3,
> but, imo, it is not a problem, since kernel does:

It changes the alignment of the datastructures in userspace.

> I haven't thought of 'aligned_u64' for this case.
> For counters and masks it would be perfect, but here user is
> passing real pointers to key and value, so they have to
> be 'void __user *', otherwise user would need to type cast
> them, which I want to avoid.

The cost of the compat layer must be considered and weighted
against this cast, which I think is really no big deal.

> I think compat layer is a better option.

It's overhead you'll have to support forever, I think you should
reconsider.

All of the "ugly casting" will be hidden, or can be hidden, in the
syscall wrappers and/or interfaces in userspace.
