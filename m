From: kuznet@ms2.inr.ac.ru
Subject: Re: Patch for NETLINK_TCPDIAG
Date: Wed, 21 May 2003 06:26:15 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305210226.GAA13667@dub.inr.ac.ru>
References: <OF172D8043.CEAC83BF-ON88256D2C.0066D5DE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kumarkr@us.ibm.com (Krishna Kumar)
In-Reply-To: <OF172D8043.CEAC83BF-ON88256D2C.0066D5DE@us.ibm.com> from "Krishna Kumar" at May 20, 2003 11:49:43 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I am not sure if there is a reason why ACK cannot be set for
> NETLINK_TCPDIAG.

No reasons, indeed.

> If it is settable, please apply following patch.

OK.


> diff -ruN linux-2.5.68.org/net/ipv4/tcp_diag.c linux-2.5.68/net/ipv4/tcp_diag.c
> --- linux-2.5.68.org/net/ipv4/tcp_diag.c  2003-05-20 11:38:06.000000000 -0700
> +++ linux-2.5.68/net/ipv4/tcp_diag.c      2003-05-20 11:39:48.000000000 -0700
> @@ -609,7 +609,7 @@
>             if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
>                   return;
>             err = tcpdiag_rcv_msg(skb, nlh);
> -           if (err)
> +           if (err || nlh->nlmsg_flags & NLM_F_ACK)
>                   netlink_ack(skb, nlh, err);
>       }
>  }
> 
