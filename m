From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPv6 IPComp
Date: Fri, 16 May 2003 23:40:18 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0305162329230.17250-100000@excalibur.intercode.com.au>
References: <87llx72imk.wl@karaba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitsuru KANDA / =?ISO-2022-JP?B?GyRCP0BFRBsoQiAbJEI9PBsoQg==?= <mk@linux-ipv6.org>
In-Reply-To: <87llx72imk.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 May 2003, Mitsuru KANDA / [ISO-2022-JP] 神田 充 wrote:

> This patch is implementation of IPComp for IPv6.
> I moved IPcompv4/v6 common definitions to net/ipcomp.h
> and also moved IPcomp header structures to general header files
> (linux/{ip.h,ipv6.h}).
> 
> Attached diff is for linux-2.5.69 + CS1.1137 .
> 
> Could you check it?
> 

Looks good!

A few issues:

The crypto/Kconfig file needs to be updated so that the deflate module is 
enabled when ipcomp6 is.

In a subsequent patch, it would be good to define single NIP6() in a 
header file, as local versions are spreading.

With current bk, you need to attach internal ipip xfrms to allow reception
of uncompressed ipcomp packets in tunnel mode.  See the current ipv4
ipcomp code as an example.  Any generic code for this should probably live
in net/xfrm/xfrm_tunnel.c


- James
-- 
James Morris
<jmorris@intercode.com.au>
