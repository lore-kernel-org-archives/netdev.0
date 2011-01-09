From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2 caching and batch mode
Date: Sun, 9 Jan 2011 09:53:16 -0800
Message-ID: <20110109095316.0e20e568@nehalam>
References: <0befc7c09f04936c1244eaa5a1d2620c@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42195 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640Ab1AIRxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jan 2011 12:53:19 -0500
In-Reply-To: <0befc7c09f04936c1244eaa5a1d2620c@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 08 Jan 2011 22:09:39 +0200
<denys@visp.net.lb> wrote:

> Hi,
> 
> noticed some issue a while ago, and because of recent patches decided to
> post my thoughts:
> 
> This issue can happen if ip or tc running in some kind of "daemon" batch
> mode, or processing large batch file on computer where interfaces can
> reappear with same name but different index (pppoe NAS for example).
> 
> It is easy to reproduce the problem:
> 
> centaur iproute2-2.6.37 # ip/ip -force -batch -
> tunnel add test0 mode ipip remote 1.1.1.2 local 1.1.1.1
> link show dev test0
> 201: test0: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN 
>     link/ipip 1.1.1.1 peer 1.1.1.2
> tunnel del test0
> Unsupported family:17
> 
> Or:
> 
> centaur iproute2-2.6.37 # ip/ip -force -batch -
> tunnel del test0
> tunnel add test0 mode ipip remote 1.1.1.2 local 1.1.1.1
> link show dev test0
> 202: test0: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN 
>     link/ipip 1.1.1.1 peer 1.1.1.2
> (another console, delete and create again test0)
> link show dev test0
> (nothing will appear)
> 

This is one of the reasons caching names seems to be a bad idea.
Caching ifindex is okay because it normally does not change.

The point of batch mode was to allow complex setup scripts to
avoid the overhead of repeated invocations. Using it as a long
running daemon was not something I thought about, and frankly
seems like a bad idea for general usage.
