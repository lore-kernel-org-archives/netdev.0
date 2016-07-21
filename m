From: Ilan Tayari <ilant@mellanox.com>
Subject: RE: IPv6 IPSec incompatibilities between 2.6.23 and 3.6.18/4.6.4
Date: Thu, 21 Jul 2016 14:40:57 +0000
Message-ID: <AM4PR0501MB1940C0DFCF936A7957D88971DB090@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEC70@ExMbx1.iabg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Pommnitz_J=F6rg?= <Pommnitz@iabg.de>,
	Shanker Wang <shankerwangmiao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0047.outbound.protection.outlook.com ([104.47.2.47]:5696
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751553AbcGUOlI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 10:41:08 -0400
In-Reply-To: <DD56476BFBBCB94EA5C5CCFF543EBEC99A0DEC70@ExMbx1.iabg.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Node 1: fd01:1b10:1000::1 is running 4.6.4
> 14:21:50.737092 IP6 fd01:1b10:1000::3 > ff0e::1:
> ESP(spi=0x00000001,seq=0x100), length 136
> 14:21:51.737155 IP6 fd01:1b10:1000::3 > ff0e::1:
> ESP(spi=0x00000001,seq=0x101), length 136
...
> ip -s xfrm state
> src fd01:1b10:1000::1 dst ff0e::1
>         proto esp spi 0x00000001(1) reqid 0(0x00000000) mode tunnel
...
>           add 2016-07-21 14:18:08 use -
...
>         dir out ...
...
>           add 2016-07-21 14:18:08 use -
...
>         dir fwd ...
>           add 2016-07-21 14:18:08 use -
...
>         dir in ...
>           add 2016-07-21 14:18:08 use -

Hi Joerg,

See the "use -" instead of a date/time of last usage (like in your output from 2.6)
Packets are received, but nothing is matched to your xfrm states and policies.

Are you sure this is the full output of "ip -s xfrm policy"? I feel like something is missing.

At first glance I'd say it looks like src+dst doesn't match the packets.
Packet source-ip is ::3, while xfrm-state source ip matches::1

Ilan.
