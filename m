From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v6 4/6] bpf: Add support for reading socket
 family, type, protocol
Date: Wed, 30 Nov 2016 21:53:17 -0800
Message-ID: <20161201055314.GA42375@ast-mbp.thefacebook.com>
References: <1480529810-25850-1-git-send-email-dsa@cumulusnetworks.com>
 <1480529810-25850-5-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33719 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbcLAGGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 01:06:11 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so3572479pgd.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 22:06:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480529810-25850-5-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 10:16:48AM -0800, David Ahern wrote:
> Add socket family, type and protocol to bpf_sock allowing bpf programs
> read-only access.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
...
> +static u32 convert_sock_access(int sock_field, int dst_reg, int src_reg,
> +			       struct bpf_insn *insn_buf)
> +{
> +	struct bpf_insn *insn = insn_buf;
> +
> +	switch (sock_field) {
> +	case SOCKF_AD_TYPE:
> +		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
> +				      offsetof(struct sock, __sk_flags_offset));
> +		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, SK_FL_TYPE_MASK);
> +		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, SK_FL_TYPE_SHIFT);
> +		break;

Wasn't that complex after all? ;)
This part looks good.

> +	case offsetof(struct bpf_sock, type):
> +		return convert_sock_access(SOCKF_AD_TYPE, dst_reg, src_reg,
> +					   insn_buf);

my only request-for-change is to place the above 3 lines of *insn++ here
instead of adding new helper function for it.
In case of skb it was a helper, because it was called from different places.
Here this is the only place where it ever be needed, so extra helper
only confuses the reader.

The rest of the patches look good to me.
I'm not Ack-ing them yet, since you didn't carry over my Ack
from the first patch and I had to re-review it again this time.

Thanks.
