From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Question: routing packets via specific router in LAN?
Date: Mon, 3 Sep 2012 08:28:37 +0000 (UTC)
Message-ID: <k21pnk$bbf$1@ger.gmane.org>
References: <50444880.8080703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:36178 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755080Ab2ICI2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 04:28:48 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1T8S1Y-00054N-5b
	for netdev@vger.kernel.org; Mon, 03 Sep 2012 10:28:48 +0200
Received: from 112.132.136.158 ([112.132.136.158])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2012 10:28:48 +0200
Received: from xiyou.wangcong by 112.132.136.158 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2012 10:28:48 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Sep 2012 at 06:04 GMT, Yi Li <lovelylich@gmail.com> wrote:
> Hi All,
> I have server --- router ---client three machines,
> and they all have only one ip in the same LAN.
> I want to instruct the packets flowing through the router when the
> server and client communicates.
> I have do the following things to setup:
> on the server:
> # ip route add to unicast CLIENT_IP/32 via ROUTER_IP dev eth0
> # echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
> # echo 0 > /proc/sys/net/ipv4/conf/eth0/accept_redirects
>
> on the client:
> /*modify route table*/
> # ip route add to unicast SERVER_IP/32 via ROUTER_IP dev eth0
> /*disable icmp-redirects accept*/
> # echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
> # echo 0 > /proc/sys/net/ipv4/conf/eth0/accept_redirects
>
> on the router:
> /*enable forwarding*/
> # echo 1 > /proc/sys/net/ipv4/ip_forwarding
> /*disable icmp-redirects*/
> # echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
> # echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
>

Try to add some iptables rules like:

iptables -A FORWARD -j ACCEPT -s CLIENT_IP/xx -d  SERVER_IP/xx
