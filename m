From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Sat, 15 Mar 2014 12:18:44 -0700
Message-ID: <CAMEtUuzF8CG6BSRyU0eUajAaiqAENNO2Za=XRz1=xqgxG8aggA@mail.gmail.com>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
	<531EE5A2.7090501@redhat.com>
	<CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
	<20140312091500.GA4638@localhost>
	<CAMEtUuztfWniTr+3u6ttuygvG=xYdp0ANn_w9MGqacQvHrXtWA@mail.gmail.com>
	<20140313122913.GA4898@localhost>
	<CAMEtUuwV2=8sVdmfKSOytC8LKsw2RX+fgfxvucSVV0=L0XEkOg@mail.gmail.com>
	<20140314181600.GA2809@localhost>
	<CAMEtUuzFkCgpvMy-V5iZycfpLQmebc_Jq-MedD=FJn-EEDkdcg@mail.gmail.com>
	<20140315190301.GA4458@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140315190301.GA4458@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 15, 2014 at 12:03 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Fri, Mar 14, 2014 at 09:04:50PM -0700, Alexei Starovoitov wrote:
> [...]
>> In the patches I sent, ebpf is _not_ exposed to the user.
>
> From your last patch: http://patchwork.ozlabs.org/patch/329713/
>
> diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
> index 8eb9ccaa5b48..4e98fe16ba88 100644
> --- a/include/uapi/linux/filter.h
> +++ b/include/uapi/linux/filter.h
> @@ -1,5 +1,6 @@
>  /*
>   * Linux Socket Filter Data Structures
> + * Extended BPF is Copyright (c) 2011-2014, PLUMgrid, http://plumgrid.com
>   */
>
>  #ifndef _UAPI__LINUX_FILTER_H__
> @@ -19,7 +20,7 @@
>   *     Try and keep these values and structures similar to BSD,
>   *     especially
>   *     the BPF code definitions which need to match so you can share
>   *     filters
>   */
> -
> +
>  struct sock_filter {   /* Filter block */
>         __u16   code;   /* Actual filter code */
>         __u8    jt;     /* Jump true */
> @@ -27,6 +28,14 @@  struct sock_filter {        /* Filter block */
>         __u32   k;      /* Generic multiuse field */
>  };
>
> +struct sock_filter_ext {
> +       __u8    code;    /* opcode */
> +       __u8    a_reg:4; /* dest register */
> +       __u8    x_reg:4; /* source register */
> +       __s16   off;     /* signed offset */
> +       __s32   imm;     /* signed immediate constant */
> +};
> +
>  struct sock_fprog {    /* Required for SO_ATTACH_FILTER. */
>         unsigned short          len;    /* Number of filter blocks */
>         struct sock_filter __user *filter;
>
> That sock_filter_ext structure is exposed to userspace as well as many
> other new BPF_* macros that you have defined.

For the first few versions of the patchset they were in linux/bpf.h,
but then it was suggested to put them into uapi/linux/filter.h
to make the whole thing consistent with existing sock_filter structure.
So yes, uapi header is changed as:
 include/uapi/linux/filter.h |   33 ++++++++++++++++++++++++++-------
 1 file changed, 26 insertions(+), 7 deletions(-)

but there is no way to use these #define from user space at present.

As I said I think it's safe to expose it, because these defines won't change,
but if there is a concern I can move it back into linux/bpf.h

Thanks
Alexei
