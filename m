From: W Agtail <wagtail@iol.ie>
Subject: Re: two gateways with one NIC
Date: Mon, 09 Apr 2007 16:56:20 +0100
Message-ID: <1176134180.686.102.camel@owl.home.ie>
References: <1176003353.686.45.camel@owl.home.ie>
	 <20070408150123.GA3511@csclub.uwaterloo.ca>
	 <1176048615.686.78.camel@owl.home.ie>
	 <20070408182210.GJ3508@csclub.uwaterloo.ca>
	 <1176060547.686.95.camel@owl.home.ie>
	 <20070409145403.GB2299@csclub.uwaterloo.ca>
Reply-To: wagtail@iol.ie
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc1-york1-0-0-cust229.leed.cable.ntl.com ([82.3.204.230]:51139
	"EHLO owl.home.ie" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965990AbXDIP42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 11:56:28 -0400
In-Reply-To: <20070409145403.GB2299@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-04-09 at 10:54 -0400, Lennart Sorensen wrote:
> On Sun, Apr 08, 2007 at 08:29:07PM +0100, W Agtail wrote:
> > This is what I'm trying to achieve with the following iptables/iproute2
> > configuration on both web servers:
> > 
> > iptables -t mangle -A PREROUTING -p tcp --dport 8088 -i eth0 -j LOG
> > --log-prefix "fwmark 1: "
> > iptables -t mangle -A PREROUTING -p tcp --dport 8089 -i eth0 -j LOG
> > --log-prefix "fwmark 2: "
> > 
> > iptables -t mangle -A PREROUTING -p tcp --dport 8088 -i eth0 -j MARK
> > --set-mark 1
> > iptables -t mangle -A PREROUTING -p tcp --dport 8089 -i eth0 -j MARK
> > --set-mark 2
> 
> You are supposed to mangle things _coming_ from port 8088 and 8089.
> After all it is the replies you are trying to affect, not the requests.
> So it should be the --sport not --dport.  And of course outbound not
> incoming on eth0.
> 
> > iptables -t mangle -A PREROUTING -m mark --mark 1 -j LOG --log-prefix
> > "marked 1: "
> > iptables -t mangle -A PREROUTING -m mark --mark 2 -j LOG --log-prefix
> > "marked 2: "
> > 
> > ip route add table 1 default via 10.18.35.11 dev eth0 # GW1
> > ip route add table 2 default via 10.18.35.21 dev eth0 # GW2
> > 
> > ip rule add fwmark 1 table 1
> > ip rule add fwmark 2 table 2
> > 
> > On web2, the default gw is set to gw2 and in /var/log/messages, I can
> > see packets appear to be marked. However, for some reason, 8088 is still
> > routing back via gw2 (default gw) rather than being routed via gw1,
> > which I'm trying to do with the above ip rules etc.
> > 
> > Is the above the correct syntax? or I guess I could totally be missing
> > the plot?
> > 
> > Many thanks for your time on this one.
> 
> Hope that helps.
> 
> --
> Len Sorensen

Hi there, and thanks v. much for getting back to me on this one.
I now have changed iptables on the web servers to the following:

iptables -t mangle -A POSTROUTING -p tcp --sport 8088 -o eth0 -j MARK
--set-mark 1
iptables -t mangle -A POSTROUTING -p tcp --sport 8089 -o eth0 -j MARK
--set-mark 2

But I'm still seeing traffic being returned via gw2 for port 8088 :(
Any ideas? Thanks.

