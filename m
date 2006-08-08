From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take5 3/4] kevent: Network AIO, socket notifications.
Date: Tue, 8 Aug 2006 11:52:53 +0200
Message-ID: <200608081152.53860.dada1@cosmosbay.com>
References: <1155023088998@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:15264 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S932181AbWHHJw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 05:52:56 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <1155023088998@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 August 2006 09:44, Evgeniy Polyakov wrote:
> Network AIO, socket notifications.
>
> This patchset includes socket notifications and network asynchronous IO.
> Network AIO is based on kevent and works as usual kevent storage on top
> of inode.

diff --git a/include/net/sock.h b/include/net/sock.h
index 324b3ea..c43a153 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h

Why are you moving around SOCKET_I() and SOCK_INODE() ?

diff --git a/kernel/kevent/kevent_naio.c b/kernel/kevent/kevent_naio.c
new file mode 100644
index 0000000..98c357f
--- /dev/null
+++ b/kernel/kevent/kevent_naio.c

> +	if (!file->f_dentry || !file->f_dentry->d_inode)
> +		goto err_out_fput;
> +	if (file->f_op != &socket_file_ops)
> +		goto err_out_fput;
> +
> +	sk = SOCKET_I(file->f_dentry->d_inode)->sk;
> +


You dont need to acess the dentry to get the socket from the file pointer.

(cf net/socket.c , function sock_from_file())

if (file->f_op != &socket_file_ops)
	goto err_out_fput;
sk = file->private_data;

(I repeat myself on this point, because I have a patch here so that only one 
common dentry is allocated for all the sockets to reduce ram usage on big 
servers : Everything but /proc/pid/fd is fine)

Eric


