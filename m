From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 18/27] bpf: Restrict kernel image access functions when
 the kernel is locked down
Date: Thu, 19 Oct 2017 16:31:08 -0700
Message-ID: <20171019233105.5ladqpdf2me36j7q@ast-mbp>
References: <20171019221829.7m5nczg3ltqmhzom@ast-mbp>
 <150842463163.7923.11081723749106843698.stgit@warthog.procyon.org.uk>
 <150842476953.7923.18174368926573855810.stgit@warthog.procyon.org.uk>
 <482.1508453314@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jlee-IBi9RG/b67k@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jforbes-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <482.1508453314-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-efi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 19, 2017 at 11:48:34PM +0100, David Howells wrote:
> Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > > @@ -65,6 +65,11 @@ BPF_CALL_3(bpf_probe_read, void *, dst, u32, size, const void *, unsafe_ptr)
> > >  {
> > >  	int ret;
> > >  
> > > +	if (kernel_is_locked_down("BPF")) {
> > > +		memset(dst, 0, size);
> > > +		return -EPERM;
> > > +	}
> >
> > That doesn't help the lockdown purpose.
> > If you don't trust the root the only way to prevent bpf read
> > memory is to disable the whole thing.
> > Have a single check in sys_bpf() to disallow everything if kernel_is_locked_down()
> > and don't add overhead to critical path like bpf_probe_read().
> 
> TBH, I've no idea how bpf does anything, so I can't say whether this is
> better, overkill or insufficient.

ok. To make it clear:
Nacked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
For the current patch.
Unnecessary checks for no good reason in performance critical
functions are not acceptable.
