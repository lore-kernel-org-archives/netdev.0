From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] bpf: devmap: Check attr->max_entries more carefully
Date: Mon, 16 Oct 2017 00:13:43 +0200
Message-ID: <100542240.i6NpMmsy5C@blindfold>
References: <20171015220020.8157-1-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        sp3485@columbia.edu
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171015220020.8157-1-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 16. Oktober 2017, 00:00:20 CEST schrieb Richard Weinberger:
> max_entries is user controlled and used as input for __alloc_percpu().
> This function expects that the allocation size is a power of two and
> less than PCPU_MIN_UNIT_SIZE.
> Otherwise a WARN() is triggered.

On a second though, I think we should also have a hard limit for ->max_entries 
or check for an overflow here:

static u64 dev_map_bitmap_size(const union bpf_attr *attr)
{
        return BITS_TO_LONGS(attr->max_entries) * sizeof(unsigned long);
}

Thanks,
//richard
