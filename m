From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH] tun: don't zeroize sock->file on detach
Date: Tue, 21 Aug 2012 20:04:41 +0400
Message-ID: <5033B199.6080305@parallels.com>
References: <20120809124436.5156.26944.stgit@localhost.localdomain> <20120809.161639.1789560369123168415.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "dhowells@redhat.com" <dhowells@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rick.jones2@hp.com" <rick.jones2@hp.com>,
	"ycheng@google.com" <ycheng@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<mikulas@artax.karlin.mff.cuni.cz>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:52428 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757864Ab2HUQEt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 12:04:49 -0400
In-Reply-To: <20120809.161639.1789560369123168415.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10.08.2012 03:16, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> From: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Date: Thu, 09 Aug 2012 16:50:40 +0400
>
>> This is a fix for bug, introduced in 3.4 kernel by commit
>> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other things,=
 replaced
>> simple sock_put() by sk_release_kernel(). Below is sequence, which l=
eads to
>> oops for non-persistent devices:
>>
>> tun_chr_close()
>> tun_detach()				<=3D=3D tun->socket.file =3D NULL
>> tun_free_netdev()
>> sk_release_sock()
>> sock_release(sock->file =3D=3D NULL)
>> iput(SOCK_INODE(sock))			<=3D=3D dereference on NULL pointer
>>
>> This patch just removes zeroing of socket's file from __tun_detach()=
=2E
>> sock_release() will do this.
>>
>> Cc: stable@vger.kernel.org
>> Reported-by: Ruan Zhijie <ruanzhijie@hotmail.com>
>> Tested-by: Ruan Zhijie <ruanzhijie@hotmail.com>
>> Acked-by: Al Viro <viro@ZenIV.linux.org.uk>
>> Acked-by: Eric Dumazet <edumazet@google.com>
>> Acked-by: Yuchung Cheng <ycheng@google.com>
>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
>
> Applied, thanks.
>

Hi, David.
I found out, that this commit: b09e786bd1dd66418b69348cb110f3a64764626a
was previous attempt to fix the problem.
I believe this commit have to be dropped.


--=20
Best regards,
Stanislav Kinsbursky
