From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] iproute2: Add support for connmark action
Date: Sat, 21 Feb 2015 16:51:34 -0800
Message-ID: <20150221165134.4f6970da@urahara>
References: <1424019439-21042-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38472 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbbBVAvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 19:51:41 -0500
Received: by padbj1 with SMTP id bj1so17855640pad.5
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 16:51:41 -0800 (PST)
In-Reply-To: <1424019439-21042-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Feb 2015 11:57:19 -0500
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Felix Fietkau <nbd@openwrt.org>
> 
> Add ability to add the netfilter connmark support.
> 
> Typical usage:
> ...lets tag outgoing icmp with mark 0x10..
> iptables -tmangle -A PREROUTING -p icmp -j CONNMARK --set-mark 0x10
> ..add on ingress of $ETH an extractor for connmark...
> tc filter add dev $ETH parent ffff: prio 4 protocol ip \
> u32 match ip protocol 1 0xff \
> flowid 1:1 \
> action connmark continue
> ...if the connmark was 0x11, we police to a ridic rate of 10Kbps
> tc filter add dev $ETH parent ffff: prio 5 protocol ip \
> handle 0x11 fw flowid 1:1 \
> action police rate 10kbit burst 10k
> 
> Other ways to use the connmark is to supply the zone, index and
> branching choice. Refer to help.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

This depends on tc_connmark.h which is a kernel header.
it is in the right place in the kernel source (include/uapi/linux/tc_connmark.h)
but is not exported because there is no entry for the file in
include/uapi/linux/tc_act/Kbuild

Please fix upstream kernel, and the I will add this back to iproutew
