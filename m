From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: TCP connection stops after high load.
Date: Sun, 15 Apr 2007 18:49:06 +0300
Message-ID: <7e63f56c0704150849r5b019962v296b4266021a6fe1@mail.gmail.com>
References: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>
	 <20070412.141550.133265618.davem@davemloft.net>
	 <7e63f56c0704150514q3b1271e8lcc9e8f30387d7540@mail.gmail.com>
	 <46224561.9010801@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	greearb@candelatech.com
To: "John Heffner" <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:6688 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbXDOPtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2007 11:49:07 -0400
Received: by ug-out-1314.google.com with SMTP id 44so912668uga
        for <netdev@vger.kernel.org>; Sun, 15 Apr 2007 08:49:06 -0700 (PDT)
In-Reply-To: <46224561.9010801@psc.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

On 4/15/07, John Heffner <jheffner@psc.edu> wrote:
> Robert Iakobashvili wrote:
> > Vanilla 2.6.18.3 works for me perfectly, whereas 2.6.19.5 and
> > 2.6.20.6 do not.
> >
> > Looking into the tcp /proc entries of 2.6.18.3 versus 2.6.19.5
> > tcp_rmem and tcp_wmem are the same, whereas tcp_mem are
> > much different:
> >
> > kernel                  tcp_mem
> > ---------------------------------------
> > 2.6.18.3    12288 16384 24576
> > 2.6.19.5      3072    4096   6144

> Another patch that went in right around that time:
>
> commit 52bf376c63eebe72e862a1a6e713976b038c3f50
> Author: John Heffner <jheffner@psc.edu>
> Date:   Tue Nov 14 20:25:17 2006 -0800
>
>      [TCP]: Fix up sysctl_tcp_mem initialization.
> (This has been changed again for 2.6.21.)
>
> In the dmesg, there should be some messages like this:
> IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
> TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
> TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
> TCP: Hash tables configured (established 131072 bind 65536)
>
> What do yours say?

For the 2.6.19.5, where we have this problem:
>From dmsg:
IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
TCP established hash table entries: 16384 (order: 5, 131072 bytes)
TCP bind hash table entries: 8192 (order: 4, 65536 bytes)

#cat /proc/sys/net/ipv4/tcp_mem
3072    4096    6144

MemTotal:       484368 kB
CONFIG_HIGHMEM4G=y

Thanks,

Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://curl-loader.sourceforge.net
An open-source HTTP/S, FTP/S traffic
generating, and web testing tool.
