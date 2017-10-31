From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 2/2] samples/bpf: add a test for bpf_override_return
Date: Mon, 30 Oct 2017 18:37:16 -0700
Message-ID: <a6514f94-8b9d-02c2-da2a-d5c035a0048f@fb.com>
References: <1509398375-11927-1-git-send-email-josef@toxicpanda.com>
 <1509398375-11927-3-git-send-email-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>
To: Josef Bacik <josef@toxicpanda.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <ast@kernel.org>, <kernel-team@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509398375-11927-3-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/17 2:19 PM, Josef Bacik wrote:
> +
> +rm -f testfile.img
> +dd if=/dev/zero of=testfile.img bs=1M seek=1000 count=1
> +DEVICE=$(losetup --show -f testfile.img)
> +mkfs.btrfs -f $DEVICE
> +mkdir tmpmnt
> +./tracex7 $DEVICE
> +if [ $? -eq 0 ]
> +then
> +	echo "SUCCESS!"
> +else
> +	echo "FAILED!"
> +fi
> +losetup -d $DEVICE

nice test!

> diff --git a/samples/bpf/tracex7_kern.c b/samples/bpf/tracex7_kern.c
> new file mode 100644
> index 000000000000..a2f74f736e66
> --- /dev/null
> +++ b/samples/bpf/tracex7_kern.c
> @@ -0,0 +1,15 @@
> +#include <uapi/linux/ptrace.h>
> +#include <uapi/linux/bpf.h>
> +#include <linux/version.h>
> +#include "bpf_helpers.h"
> +
> +SEC("kprobe/open_ctree")
> +int bpf_prog1(struct pt_regs *ctx)
> +{
> +	unsigned long rc = -12;

pls add empty line here.

> +	bpf_override_return(ctx, rc);
> +	return 0;
> +}
