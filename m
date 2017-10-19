From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when the kernel is locked down
Date: Thu, 19 Oct 2017 23:48:34 +0100
Message-ID: <482.1508453314@warthog.procyon.org.uk>
References: <20171019221829.7m5nczg3ltqmhzom@ast-mbp> <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk> <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: jlee@suse.com, dhowells@redhat.com,
        linux-security-module@vger.kernel.org, gnomes@lxorguk.ukuu.org.uk,
        linux-efi@vger.kernel.org, gregkh@linuxfoundation.org,
        linux-kernel@vger.kernel.org, jforbes@redhat.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019221829.7m5nczg3ltqmhzom@ast-mbp>
Content-ID: <481.1508453314.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> > @@ -65,6 +65,11 @@ BPF_CALL_3(bpf_probe_read, void *, dst, u32, size, const void *, unsafe_ptr)
> >  {
> >  	int ret;
> >  
> > +	if (kernel_is_locked_down("BPF")) {
> > +		memset(dst, 0, size);
> > +		return -EPERM;
> > +	}
>
> That doesn't help the lockdown purpose.
> If you don't trust the root the only way to prevent bpf read
> memory is to disable the whole thing.
> Have a single check in sys_bpf() to disallow everything if kernel_is_locked_down()
> and don't add overhead to critical path like bpf_probe_read().

TBH, I've no idea how bpf does anything, so I can't say whether this is
better, overkill or insufficient.

David
