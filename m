From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: Tools for sampling ethtool --statistics
Date: Thu, 21 Jan 2016 00:34:16 +0200
Message-ID: <CAJ3xEMiNDU20FVG_9_r11wqMmAFiERBTYcsFmjwaSfbZ25NOiQ@mail.gmail.com>
References: <20160120101311.5266cac6@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35219 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591AbcATWeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 17:34:17 -0500
Received: by mail-io0-f177.google.com with SMTP id 77so35538624ioc.2
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 14:34:17 -0800 (PST)
In-Reply-To: <20160120101311.5266cac6@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 11:13 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> Hi All,
>
> I wrote a small tool[1] to extract ethtool --statistics|-S, sample and
> present it in a more human readable manor.  You might also find this
> useful...
>
> https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl
>
> The reason I wrote this script is that the mlx5 driver (Mellanox 100 Gbit/s)
> does not report correct ifconfig stats.  It reports the HW counters,
> not what the network stack is able to handle.  I/we obviously need the
> stack number when working on improving the stack.

correct && we should be fixing that ... still it's worthwhile to be
able and see per ring stats, specially when you're dealing/optimizing
in multi-stream env.

> Output examples:
>
> pktgen (1 core) sending ~20Mpps
>
> Show adapter mlx5p2 statistics (ONLY that changed!)
> Ethtool(mlx5p2) stat:     19431694 (     19,431,694) <= frames_rx /sec
> Ethtool(mlx5p2) stat:   1243722215 (  1,243,722,215) <= in_octets /sec
> Ethtool(mlx5p2) stat:     19433161 (     19,433,161) <= in_ucast_pkts /sec
> Ethtool(mlx5p2) stat:   1243746943 (  1,243,746,943) <= octets /sec
> Ethtool(mlx5p2) stat:   1243629263 (  1,243,629,263) <= octets_received /sec
> Ethtool(mlx5p2) stat:     19433654 (     19,433,654) <= p64octets /sec
> Ethtool(mlx5p2) stat:     19433556 (     19,433,556) <= pkts /sec
> Ethtool(mlx5p2) stat:      1815546 (      1,815,546) <= rx3_packets /sec
> Ethtool(mlx5p2) stat:   1165854821 (  1,165,854,821) <= rx_bytes /sec
> Ethtool(mlx5p2) stat:     19430906 (     19,430,906) <= rx_csum_good /sec
> Ethtool(mlx5p2) stat:     19430906 (     19,430,906) <= rx_packets /sec
> Ethtool(mlx5p2) stat:   1165854821 (  1,165,854,821) <= rx_unicast_bytes /sec
> Ethtool(mlx5p2) stat:     19430906 (     19,430,906) <= rx_unicast_packets /sec

was expecting to see tx_XXX stats, something wrong here?


> pktgen (4 cores) sending ~50Mpps
[...]

The 20M for single ring/core and 50M pps for four streams are really
cool results. Do the scripts to get ~such results exist in your
network testing github repo? last time I looked I wasn't sure if  the
multi-stream case is supported.

Could you post the two commands you used for these results along with
minimal spec of the system (CPU type/freq, special .config directives,
anything else)?

Or.

> Show adapter mlx5p2 statistics (ONLY that changed!)
> Ethtool(mlx5p2) stat:     25710443 (     25,710,443) <= drop_events /sec
> Ethtool(mlx5p2) stat:     51861645 (     51,861,645) <= frames_rx /sec
> Ethtool(mlx5p2) stat:     25710502 (     25,710,502) <= in_discards /sec
> Ethtool(mlx5p2) stat:   3319134161 (  3,319,134,161) <= in_octets /sec
> Ethtool(mlx5p2) stat:     26150970 (     26,150,970) <= in_ucast_pkts /sec
> Ethtool(mlx5p2) stat:   3319128053 (  3,319,128,053) <= octets /sec
> Ethtool(mlx5p2) stat:   3319145319 (  3,319,145,319) <= octets_received /sec
> Ethtool(mlx5p2) stat:     51861369 (     51,861,369) <= p64octets /sec
> Ethtool(mlx5p2) stat:     51861375 (     51,861,375) <= pkts /sec
> Ethtool(mlx5p2) stat:      1383475 (      1,383,475) <= rx3_packets /sec
> Ethtool(mlx5p2) stat:   1569059171 (  1,569,059,171) <= rx_bytes /sec
> Ethtool(mlx5p2) stat:     26150988 (     26,150,988) <= rx_csum_good /sec
> Ethtool(mlx5p2) stat:     26150988 (     26,150,988) <= rx_packets /sec
> Ethtool(mlx5p2) stat:   1569059171 (  1,569,059,171) <= rx_unicast_bytes /sec
> Ethtool(mlx5p2) stat:     26150988 (     26,150,988) <= rx_unicast_packets /sec
