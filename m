From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: don't kfree an uninitialized im_node
Date: Tue, 24 Jan 2017 09:53:34 -0800
Message-ID: <CAADnVQLZ-uAcDehoWb5ev9pHhkDy9XoEOyKQPg0qSUXw=dzOYw@mail.gmail.com>
References: <20170124141629.9200-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124141629.9200-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2017 at 6:16 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> There are some error exit paths to the label 'out' that end up
> kfree'ing an uninitialized im_node.  Fix this by inititializing
> im_node to NULL to avoid kfree'ing a garbage address.

this fix already landed. See:
commit d140199af510 ("bpf, lpm: fix kfree of im_node in trie_update_elem")

> Issue found by CoverityScan, CID#1398022 ("Uninitialized pointer read")

Nice. Good to know that static analysis can do such checks.
