From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: sendfile() behavior while troubleshooting netdevice
Date: Mon, 28 Jul 2008 19:52:42 -0500
Message-ID: <20080728195242.788f73c0@osprey.hogchain.net>
References: <20080728190707.329d247b@osprey.hogchain.net>
	<488E63DD.4020406@jeffray.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Jeffray <ian@jeffray.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([204.127.217.105]:42801 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbYG2Awo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 20:52:44 -0400
In-Reply-To: <488E63DD.4020406@jeffray.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jul 2008 01:27:09 +0100
Ian Jeffray <ian@jeffray.co.uk> wrote:


> Because you send() a strlen() amount of data for the filesize,
> but recv() a sizeof(cfsize) amount of data?   I supect 8 bytes
> is being sucked up in your first recv().  Try sending a fixed
> size block for the file size.

Thanks for the reply.  I changed strlen(fsize) to sizeof(fsize) in
sfserver.c; no difference.

[jcliburn@petrel ~]$ ./sfsrv
sending file 'testfile' size 1600 bytes
1600 bytes sent
sending file 'testfile' size 1600 bytes
1600 bytes sent
sending file 'testfile' size 1600 bytes
1600 bytes sent
sending file 'testfile' size 1600 bytes
1600 bytes sent


[jcliburn@sparrow ~]$ ./sfcli 192.168.1.6 testfile
connected...
file size is 1600 bytes
received 1592 bytes
error: expected 1600, received 1592
[jcliburn@sparrow ~]$ ./sfcli 192.168.1.6 testfile
connected...
file size is 1600 bytes
received 1600 bytes
[jcliburn@sparrow ~]$ ./sfcli 192.168.1.6 testfile
connected...
file size is 1600 bytes
received 1592 bytes
error: expected 1600, received 1592
