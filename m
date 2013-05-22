From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v3] sock_diag: notify packet socket creation/deletion
Date: Wed, 22 May 2013 13:49:03 +0200
Message-ID: <519CB0AF.5090907@6wind.com>
References: <1368800738-4364-1-git-send-email-nicolas.dichtel@6wind.com> <20130519.232925.1972249319855411715.davem@davemloft.net> <519B8F6A.7010406@6wind.com> <20130521.114356.1770768038835716108.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:61322 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab3EVLtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:49:07 -0400
Received: by mail-wi0-f182.google.com with SMTP id c10so1110716wiw.3
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 04:49:06 -0700 (PDT)
In-Reply-To: <20130521.114356.1770768038835716108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/05/2013 20:43, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue, 21 May 2013 17:14:50 +0200
>
>> Le 20/05/2013 08:29, David Miller a =E9crit :
>>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> Date: Fri, 17 May 2013 16:25:38 +0200
>>>
>>>> With this patch, a netlink message is sent each time a packet sock=
et
>>>> is created or deleted.  The framework is generic, so it's easy to
>>>> add the notification for other kind of sockets.
>>>>
>>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>
>>> Just curious what you want to use this for.
>> Some HW (custom FPGA, ASICs, NPUs) are able to offload packet
>> captures, so it is required to notify them.
>
> I don't even want to hear about this until you have patches ready
> to submit to fully support such a facility.
Not sure to understand what you're expecting. In our case, configuratio=
n is done=20
by a daemon, hence there is no other kernel patch to support this.

Note that this patch is still a complete feature, it allows to monitor =
AF_PACKET=20
socket.
With a patched iproute2:

$ ss -ap0e -M
     Netid  State      Recv-Q Send-Q=20
        Local Address:Port=20
  Peer Address:Port
     p_dgr  UNCONN     0      0=20
                    *:*=20
              *        users:(("tcpdump",8630,3)) ino=3D29477 uid=3D0 s=
k=3Df53fbc00
del p_dgr  UNCONN     0      0=20
                   *:*=20
             *        users:(("tcpdump",8630,3)) ino=3D29477 uid=3D0 sk=
=3Df53fbc00

Will you accept the patch if I integrate the example in the commit log?
