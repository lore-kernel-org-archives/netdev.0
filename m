From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 0/2] net: Remove iocb argument from sendmsg and
 recvmsg
Date: Mon, 2 Mar 2015 08:52:56 +0800
Message-ID: <54F3B468.1060204@windriver.com>
References: <1425035198-12547-1-git-send-email-ying.xue@windriver.com> <20150228.171250.1612351664541183290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <viro@ZenIV.linux.org.uk>, <hch@lst.de>, <netdev@vger.kernel.org>,
	<erik.hugne@ericsson.com>, <jon.maloy@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:44910 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbbCBAxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 19:53:12 -0500
In-Reply-To: <20150228.171250.1612351664541183290.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2015 06:12 AM, David Miller wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Fri, 27 Feb 2015 19:06:35 +0800
>=20
>> Currently there is only one user - TIPC whose sendmsg() instances
>> using iocb argument. Meanwhile, there is no user using iocb argument
>> in its recvmsg() instance. Therefore, if we eliminate the werid usag=
e
>> of iobc argument from TIPC, the iocb argument can be removed from
>> all sendmsg() and recvmsg() instances of the whole network stack.
>>
>> By the way, as patch #2 is very big, I can divide it into smaller
>> patches regarding module in next version if necessary.
>>
>> Reference:
>> https://patchwork.ozlabs.org/patch/433960/
>=20
> You didn't even properly compile test this patch series:
>=20
> net/dccp/proto.c:744:5: error: conflicting types for =A1dccp_sendmsg=A2
>  int dccp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>      ^
> In file included from net/dccp/proto.c:37:0:
> net/dccp/dccp.h:313:5: note: previous declaration of =A1dccp_sendmsg=A2=
 was here
>  int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr =
*msg,
>      ^
>  ...
> net/dccp/proto.c:808:5: error: conflicting types for =A1dccp_recvmsg=A2
>  int dccp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, in=
t nonblock,
>      ^
> In file included from net/dccp/proto.c:37:0:
> net/dccp/dccp.h:315:5: note: previous declaration of =A1dccp_recvmsg=A2=
 was here
>  int dccp_recvmsg(struct kiocb *iocb, struct sock *sk,
>      ^
>=20

Oops! When I verified it, I almost enabled all functions and modules as=
sociated
with networking except DCCP module I accidentally missed. Thank you for=
 the
report. I would carefully verified the patch again.

Regards,
Ying
