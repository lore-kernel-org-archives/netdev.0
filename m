From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 21 May 2017 23:42:37 -0400
Message-ID: <CAF=yD-LjjxR7VoXiNXid6e-c_zvVifc7wAnHxtSPeR+kyH8ung@mail.gmail.com>
References: <20170522111605.14f93676@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Miroslav Lichvar <mlichvar@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170522111605.14f93676@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 21, 2017 at 9:16 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
>
> net/socket.c: In function 'put_ts_pktinfo':
> net/socket.c:695:28: error: 'SCM_TIMESTAMPING_PKTINFO' undeclared (first use in this function)
>   put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_PKTINFO,
>                             ^
>
> Caused by commit
>
>   aad9c8c470f2 ("net: add new control message for incoming HW-timestamped packets")
>
> This probably broke every architecture that has its own
> arch/<arch>/include/uapi/asm/socket.h that does not include
> include/uapi/asm-generic/socket.h :-(

Indeed. I added the architecture specific versions in patch

  http://patchwork.ozlabs.org/patch/765238/

That fixes the powerpc build for me. The new option is now
defined in every file that also defines the last added such
option SCM_TIMESTAMPING_OPT_STATS. Apologies for
missing this earlier.
