From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3] bpf: Set register type according to is_valid_access()
Date: Mon, 26 Sep 2016 10:58:28 -0700
Message-ID: <20160926175827.GA54376@ast-mbp.thefacebook.com>
References: <20160924180150.23620-1-mic@digikod.net>
 <57E9356D.70308@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Kees Cook <keescook@chromium.org>,
        Sargun Dhillon <sargun@sargun.me>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33370 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751340AbcIZR6e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 13:58:34 -0400
Content-Disposition: inline
In-Reply-To: <57E9356D.70308@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 26, 2016 at 04:49:17PM +0200, Daniel Borkmann wrote:
> On 09/24/2016 08:01 PM, Mickaël Salaün wrote:
> >This prevent future potential pointer leaks when an unprivileged eBPF
> >program will read a pointer value from its context. Even if
> >is_valid_access() returns a pointer type, the eBPF verifier replace it
> >with UNKNOWN_VALUE. The register value that contains a kernel address is
> >then allowed to leak. Moreover, this fix allows unprivileged eBPF
> >programs to use functions with (legitimate) pointer arguments.
> >
> >Not an issue currently since reg_type is only set for PTR_TO_PACKET or
> >PTR_TO_PACKET_END in XDP and TC programs that can only be loaded as
> >privileged. For now, the only unprivileged eBPF program allowed is for
> >socket filtering and all the types from its context are UNKNOWN_VALUE.
> >However, this fix is important for future unprivileged eBPF programs
> >which could use pointers in their context.
> >
> >Signed-off-by: Mickaël Salaün <mic@digikod.net>
> >Cc: Alexei Starovoitov <ast@kernel.org>
> >Cc: Daniel Borkmann <daniel@iogearbox.net>
> 
> Seems okay to me:
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>

Mickael, please mention [PATCH net-next] in subject next time.
Thanks
