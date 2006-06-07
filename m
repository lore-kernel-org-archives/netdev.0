From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: kernel panic (on DHCP discover?) in sky2 driver of 2.6.17-rc1
Date: Wed, 7 Jun 2006 12:44:36 -0700
Message-ID: <20060607124436.20fdf9fa@localhost.localdomain>
References: <CECD6E8A589E8447BC6E836C8369AFF506828728@us-email.terastack.bluearc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37062 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932141AbWFGTo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 15:44:57 -0400
To: "Guenther Thomsen" <GThomsen@bluearc.com>
In-Reply-To: <CECD6E8A589E8447BC6E836C8369AFF506828728@us-email.terastack.bluearc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Jun 2006 12:33:21 -0700
"Guenther Thomsen" <GThomsen@bluearc.com> wrote:

> I was perhaps a bit quick to declare victory. While the results below stand and the machine survived the last few days (idle), it occurred to me only today, to have a look at the kernel's message buffer, where I found following:
> --8<--
> sky2 eth0: enabling interface
> sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control none
> sky2 eth1: enabling interface
> sky2 eth1: Link is up at 1000 Mbps, full duplex, flow control none
> audit(1149379670.514:3): audit_pid=1915 old=0 by auid=4294967295
> <unknown>: hw csum failure.
> sky2 eth1: rx error, status 0x7ffc0001 length 444
> 
> Call Trace: <ffffffff811de741>{__skb_checksum_complete+76}
>        <ffffffff812030cb>{__tcp_checksum_complete_user+33}
>        <ffffffff812080d8>{tcp_rcv_established+817} <ffffffff8120f3ee>{tcp_v4_
> do_rcv+43}
>        <ffffffff811da2ee>{sk_wait_data+203} <ffffffff811fe5a8>{tcp_prequeue_p
> rocess+121}
>        <ffffffff811ff71d>{tcp_recvmsg+1104} <ffffffff811d9712>{sock_common_re
> cvmsg+48}
>        <ffffffff811d7d4f>{do_sock_read+209} <ffffffff811d7e7e>{sock_aio_read+
> 83}
>        <ffffffff811e2ca1>{dev_queue_xmit+0} <ffffffff8106dce9>{do_sync_read+1
> 99}
>        <ffffffff8103d699>{remove_wait_queue+18} <ffffffff8103d530>{autoremove
> _wake_function+0}
>        <ffffffff8106df83>{vfs_read+228} <ffffffff8106ea12>{sys_read+69}
>        <ffffffff81009b0d>{tracesys+209}
> <unknown>: hw csum failure.
> sky2 eth1: rx error, status 0x7ffc0001 length 444

Different problem, I have seen it before.  Basically if the receiver gets overloaded, the
packet FIFO gets full. The driver needs to have some kind of recovery logic for this;
probably just shutting down the receiver and restarting.
