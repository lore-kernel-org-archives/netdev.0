From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Sun, 15 Mar 2015 21:47:00 +0100
Message-ID: <5505EFC4.1070403@iogearbox.net>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37058 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097AbbCOUrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 16:47:03 -0400
In-Reply-To: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vadim,

On 03/03/2015 05:41 PM, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
>
> It is possible to use class names from file /etc/iproute2/cls_names
> which tc will use when showing class info:
>
>      # tc/tc -nm class show dev lo
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
>      # tc/tc -nm -cf /tmp/cls_names class show dev lo
>
> Class names file contains simple "maj:min  name" structure:
>
> 1:20    web
> 1:40    voip
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

in your patch, there are a couple of malloc() calls in your db
creation, that you should check if they actually fail, see i.e.
db_names_alloc(). Would be good if you could follow-up with a fix.

Thanks,
Daniel
