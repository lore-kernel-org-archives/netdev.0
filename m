From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: TCP connection stops after high load.
Date: Sun, 15 Apr 2007 15:14:44 +0300
Message-ID: <7e63f56c0704150514q3b1271e8lcc9e8f30387d7540@mail.gmail.com>
References: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>
	 <20070412.141550.133265618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:24716 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbXDOMOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2007 08:14:45 -0400
Received: by ug-out-1314.google.com with SMTP id 44so884715uga
        for <netdev@vger.kernel.org>; Sun, 15 Apr 2007 05:14:44 -0700 (PDT)
In-Reply-To: <20070412.141550.133265618.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/13/07, David Miller <davem@davemloft.net> wrote:
> From: "Robert Iakobashvili" <coroberti@gmail.com>
> Date: Thu, 12 Apr 2007 23:11:14 +0200
>
> > It works good with  2.6.11.8 and debian 2.6.18.3-i686 image.
> >
> > At the same Intel Pentium-4 PC with the same about kernel configuration
> > (make oldconfig using Debian config-2.6.18.3-i686) the setup fails with the
> > tcp-connections stalled after 1000 established connections when the kernel
> > is 2.6.20.6 or 2.6.19.5.
> >
> > It stalls even earlier, when lighttpd used with the default (poll ())
> > demultiplexing
> > after 500 connections or when apache2 web server used (memory?) - after 100
> > connections.
> >
> > I am currently going to try vanilla 2.6.18.3 and, if with it also
> > fails, to look through
> > Debian patches, trying to figure out, what is the delta.

Vanilla 2.6.18.3 works for me perfectly, whereas 2.6.19.5 and
2.6.20.6 do not.

Looking into the tcp /proc entries of 2.6.18.3 versus 2.6.19.5
tcp_rmem and tcp_wmem are the same, whereas tcp_mem are
much different:

kernel                  tcp_mem
---------------------------------------
2.6.18.3    12288 16384 24576
2.6.19.5      3072    4096   6144


Is not it done deliberately by the below patch:

commit 9e950efa20dc8037c27509666cba6999da9368e8
Author: John Heffner <jheffner@psc.edu>
Date:   Mon Nov 6 23:10:51 2006 -0800

    [TCP]: Don't use highmem in tcp hash size calculation.

    This patch removes consideration of high memory when determining TCP
    hash table sizes.  Taking into account high memory results in tcp_mem
    values that are too large.

Is it a feature?

My machine has:
MemTotal:       484368 kB
and
for all kernel configurations are actually the same with
CONFIG_HIGHMEM4G=y

Thanks,

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://curl-loader.sourceforge.net
An open-source HTTP/S, FTP/S traffic
generating, and web testing tool.
