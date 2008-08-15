From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Fri, 15 Aug 2008 23:36:05 +0300
Message-ID: <200808152336.05424.denys@visp.net.lb>
References: <20080815190905.M56388@visp.net.lb> <48A5E42B.8060903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:35749 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761642AbYHOUhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 16:37:11 -0400
In-Reply-To: <48A5E42B.8060903@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 15 August 2008, Jarek Poplawski wrote:
> Denys Fedoryshchenko wrote, On 08/15/2008 09:09 PM:
> > Aug 15 21:59:54 192.168.20.66 [ 1123.800035] BUG: unable to handle kernel
> > Aug 15 21:59:54 192.168.20.66 NULL pointer dereference
> > Aug 15 21:59:54 192.168.20.66 at 00000004
> > Aug 15 21:59:54 192.168.20.66 [ 1123.800035] IP:
> > Aug 15 21:59:54 192.168.20.66 [<c0272579>] qdisc_dequeue_head+0x29/0x3d
>
> Could you add some details like:
> - device(eth, ppp, ifb...), net driver(s) on that device,
> - types of filters, actions on the path to this tbf queue,
> - were there any config changes done around the time when this happened?
>
> Thanks,
> Jarek P.


TBF on ppp
Probably multiple ppp interfaces coming up. (but tbf applied on each 
separately)

Rules, qdiscs and filters looks like this:

    echo "qdisc del dev $2 root"
    echo "qdisc add dev $2 root handle 1: prio"
    echo "qdisc add dev $2 parent 1:1 handle 2: est 1sec 8sec tbf buffer 
${burst} latency 500ms rate ${rate}bit peakrate ${peakrate}bit mtu 1512"
#    echo "Bypass code"
# !!!!!!!!!!!!!!!!!!WRONG!!!!!!!!!!!!
    echo "qdisc add dev $2 parent 1:1 handle 3: tbf buffer ${burst}kb latency 
500ms rate 1024000"
    echo "filter add dev $2 parent 1:0 protocol ip prio 5 u32 match ip src 
194.146.153.24/32 flowid 3:1"
    echo "filter add dev $2 parent 1:0 protocol ip prio 5 u32 match ip src 
194.146.153.26/32 flowid 3:1"
    echo "filter add dev $2 parent 1:0 protocol ip prio 5 u32 match ip src 
194.146.153.6/32 flowid 3:1"
    echo "filter add dev $2 parent 1:0 protocol ip prio 5 u32 match ip src 
194.146.153.19/32 flowid 3:1"
    echo "filter add dev $2 parent 1:0 protocol ip prio 5 u32 match ip src 
2.2.2.102/32 flowid 3:1"
    echo "filter add dev $2 parent 1:0 protocol ip prio 5 u32 match ip src 
2.2.2.105/32 flowid 3:1"
    echo "filter add dev $2 parent 1:0 protocol ip prio 5 u32 match ip src 
2.2.2.106/32 flowid 3:1"
#TEMP BYPASS CODE
#    echo "Final rule"
    echo "filter add dev $2 parent 1:0 protocol ip prio 10 u32 match ip dst 
0.0.0.0/0 flowid 2:1"                                                          

