From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] l2tp: avoid checksum offload for fragmented packets
Date: Mon, 3 Jun 2013 15:44:12 +0100
Message-ID: <1370270652.1918.14.camel@bwh-desktop.uk.level5networks.com>
References: <1370245762-5126-1-git-send-email-tparkin@katalix.com>
	 <1370245762-5126-2-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jchapman@katalix.com>
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37872 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229Ab3FCOoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 10:44:15 -0400
In-Reply-To: <1370245762-5126-2-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 08:49 +0100, Tom Parkin wrote:
> Hardware offload for UDP datagram checksum calculation doesn't work with
> fragmented IP packets -- the device will note the fragmentation and leave the
> UDP checksum well alone.
> 
> As such, if we expect the L2TP packet to be fragmented by the IP layer we need
> to perform the UDP checksum ourselves in software (ref: net/ipv4/udp.c).
>
> This change modifies the L2TP xmit path to fallback to software checksum
> calculation if the L2TP packet + IP header exceeds the tunnel device MTU.
[...]

Surely this should be done in the IP stack when fragmenting, not in any
particular client?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
