From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Tue, 3 Mar 2015 09:58:45 -0800
Message-ID: <20150303095845.5aa844a0@urahara>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:45008 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbbCCR6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 12:58:44 -0500
Received: by igdh15 with SMTP id h15so30138576igd.3
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 09:58:44 -0800 (PST)
In-Reply-To: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  3 Mar 2015 18:41:18 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> It is possible to use class names from file /etc/iproute2/cls_names
> which tc will use when showing class info:
> 
>     # tc/tc -nm class show dev lo
> 	class htb 1:10 parent 1:1 leaf 10: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> 	class htb 1:1 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb web#1:20 parent 1:1 leaf 20: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb 1:2 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb 1:30 parent 1:1 leaf 30: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb voip#1:40 parent 1:2 leaf 40: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> 	class htb 1:50 parent 1:2 leaf 50: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb 1:60 parent 1:2 leaf 60: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> 
> or to specify via file path:
> 
>     # tc/tc -nm -cf /tmp/cls_names class show dev lo
> 
> Class names file contains simple "maj:min  name" structure:
> 
> 1:20    web
> 1:40    voip
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

This adds new dependency on berkely db.
See how iproute handled that for arpd and use same #ifdef and config.
