From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [BUG?] iproute2/skbedit bug?
Date: Wed, 4 Mar 2009 13:36:07 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F2C0F5D33@orsmsx501.amr.corp.intel.com>
References: <200903042146.37807.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Denys Fedoryschenko <denys@visp.net.lb>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@osdl.org" <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54627 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774AbZCDVgS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 16:36:18 -0500
In-Reply-To: <200903042146.37807.denys@visp.net.lb>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote:
> Hi
>
> trying to do test case:
>
> defaulthost ~ # tc qdisc del dev eth0 root handle 1: htb
> defaulthost ~ # tc qdisc add dev eth0 root handle 1: htb
> defaulthost ~ # tc class add dev eth0 parent 1:0 classid 1:1 htb rate
> 100Mbit ceil 100Mbit
> defaulthost ~ #
> defaulthost ~ # tc class add dev eth0 parent 1:1 classid 1:2 htb rate
> 100Mbit ceil 100Mbit
> defaulthost ~ # tc qdisc add dev eth0 parent 1:2 handle 2: pfifo
> limit 1000 defaulthost ~ #
> defaulthost ~ #
> defaulthost ~ # tc filter add dev eth0 pref 200 parent 1: protocol ip
> u32 match ip src 1.1.1.1/32 flowid 1:1 action skbedit priority 10
> defaulthost ~ # tc filter add dev eth0 pref 201 parent 1: protocol ip
> u32 match ip src 1.1.1.2/32 flowid 1:2 action skbedit priority 11
> RTNETLINK answers: File exists
> We have an error talking to the kernel
>
> As soon as skbedit involved, i am getting this strange result "File
> exists". If i change(remove) flowid, classes - seems doesn't matter
>
> Result looks like this:
> defaulthost ~ # tc -s filter show dev eth0
> filter parent 1: protocol ip pref 200 u32
> filter parent 1: protocol ip pref 200 u32 fh 800: ht divisor 1
> filter parent 1: protocol ip pref 200 u32 fh 800::800 order 2048 key
> ht 800 bkt 0 flowid 1:1  (rule hit 460 success 0)
>   match 01010101/ffffffff at 12 (success 0 )
>         action order 1:  skbedit priority :10 installed 82 sec used
> 82 sec Action statistics:
>         Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>         rate 0bit 0pps backlog 0b 0p requeues 0
>
> filter parent 1: protocol ip pref 201 u32
> filter parent 1: protocol ip pref 201 u32 fh 801: ht divisor 1
>
> If i remove skbedit:
> defaulthost ~ # tc filter add dev eth0 pref 200 parent 1: protocol ip
> u32 match ip src 1.1.1.1/32 flowid 1:1
> defaulthost ~ #

Are you using the latest version off of the git tree or the version tagged v2.6.28?  There was a fix applied 13 days ago to the git tree version which resolves an issue with uninitialized memory being used in configuring the skbedit action.  This was causing "File Exists" errors similar to what you are seeing now.

Thanks,

Alex
