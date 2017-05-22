From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 22 May 2017 11:16:05 +1000
Message-ID: <20170522111605.14f93676@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Miroslav Lichvar <mlichvar@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

net/socket.c: In function 'put_ts_pktinfo':
net/socket.c:695:28: error: 'SCM_TIMESTAMPING_PKTINFO' undeclared (first use in this function)
  put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPING_PKTINFO,
                            ^

Caused by commit

  aad9c8c470f2 ("net: add new control message for incoming HW-timestamped packets")

This probably broke every architecture that has its own
arch/<arch>/include/uapi/asm/socket.h that does not include
include/uapi/asm-generic/socket.h :-(

I have used the net-next tree from next-20170519 for today.

-- 
Cheers,
Stephen Rothwell
