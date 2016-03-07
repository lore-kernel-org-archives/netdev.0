From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Tool for sampling /proc/net/softnet_stat statistics
Date: Mon, 7 Mar 2016 12:54:13 -0500
Message-ID: <CAF=yD-LE3WnYZaNUX8h1-uRA2ZzMczrL=Ob4Qb39hhyAEqYMPA@mail.gmail.com>
References: <20160307163607.1da5f17e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	erdnetdev@gmail.com
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33176 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634AbcCGRyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:54:55 -0500
In-Reply-To: <20160307163607.1da5f17e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 10:36 AM, Jesper Dangaard Brouer
<jbrouer@redhat.com> wrote:
> Hi Google,
>
> While playing with RPS, I needed to read stats from
> /proc/net/softnet_stat and the tools I could find [1] and [2] was not
> very good.
>
> I lack of better, I coded up my own tool softnet_stat.pl here:
>  https://github.com/netoptimizer/network-testing/blob/master/bin/softnet_stat.pl
>
> The output format/columns in /proc/net/softnet_stat is undocumented,
> plus values are printed in hex.  E.g. to decode the columns you need to
> read kernel function kernel softnet_seq_show() in
> kernel/net/core/net-procfs.c.
>
> To make things easier I wrote this small perl script for get
> so human readable statistics from /proc/net/softnet_stat.

Very nice. Thanks for sharing, Jesper. I maintained something similar,
but never got around to clean up and upstream it. Will start using
yours, instead.

A few points, from using my earlier tool:

A minimum cut-off value is helpful, especially on beefy servers, to
suppress the many 0 rows. Preferably configurable, to also be able to
suppress low-rate background traffic when analyzing a few large
streams. My default was 500.

The number of columns has grown with kernel versions. The latest
column is flow_limit, added in 3.11 at99bbc7074190. It is helpful for
the script to be robust against both older and future kernels. On
which note, to be able to support these kinds of tools, any new
columns to such procfs files should be appended, not inserted as for
instance in https://patchwork.ozlabs.org/patch/574171/

Time squeeze is an exception, in that it is number of squeeze events
per second, not number of packets squeezed. This is often
misunderstood if not explained clearly.
