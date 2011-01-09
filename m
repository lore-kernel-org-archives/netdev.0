From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and
 coding-style
Date: Sun, 9 Jan 2011 13:06:08 -0800
Message-ID: <20110109130608.5c7bb4b0.rdunlap@xenotime.net>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun,  9 Jan 2011 21:55:34 +0100 Christoph Paasch wrote:

> This patch reviews the include-files of net/tcp.h
> Several #include where redundant. Some where not directly needed by
> net/tcp.h
> 
> Files, including net/tcp.h where also including some the *.h-files that
> net/tcp.h is already including. Thus, in these files the inclusion of
> the *.h file is unnecessary.
> 
> Redundant includes in net/tcp.h:
> 
> linux/list.h --- included by linux/textsearch.h which is included by
>                  linux/skbuff.h

If there is something in net/tcp.h that uses data or functions from <linux/list.h>,
then <linux/list.h> should be #included in net/tcp.h, whether some other file
pulls it in indirectly or not.

etc. etc. etc.

> linux/slab.h --- included by linux/crypto.h
> linux/cache.h --- included by linux/skbuff.h
> linux/skbuff.h --- included by net/sock.h
> linux/kref.h --- included by linux/kobject.h, which is  included by
>                  linux/device.h, which is included by
>                  linux/dmaengine.h, which is included by
>                  linux/skbuff.h
> net/inet_connection_sock.h --- included by net/inet_hashtables.h
> net/checksum.h --- included by net/sock.h
> net/request_sock.h --- included by net/inet_connection_sock.h
> net/sock.h --- included by net/request_sock.h
> net/snmp.h --- included by net/ip.h
> net/dst.h --- included by net/sock.h
> linux/seq_file.h --- included by net/neighbour.h, which is included by
>                      net/dst.h
> 
> Include-files not directly needed by net/tcp.h:
> 
> linux/percpu.h
> linux/dmaengine.h
> net/tcp_states.h
> net/inet_ecn.h

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
