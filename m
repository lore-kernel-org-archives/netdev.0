From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8409] New: e1000 : checksum incorrect for eth0
 but not for ppp0 packets
Date: Mon, 30 Apr 2007 11:07:44 -0700
Message-ID: <20070430110744.85b0eb06.akpm@linux-foundation.org>
References: <200704301629.l3UGTuVb026811@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, toralf.foerster@gmx.de
To: Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59977 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423512AbXD3SIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 14:08:02 -0400
In-Reply-To: <200704301629.l3UGTuVb026811@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Apr 2007 09:29:56 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8409
> 
>            Summary: e1000 : checksum incorrect for eth0 but not for ppp0
>                     packets
>     Kernel Version: 2.6.20-gentoo-r7
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: toralf.foerster@gmx.de
> 
> 
> Most recent kernel where this bug did *NOT* occur:
> Distribution: Gentoo (stale)
> Hardware Environment: ThinkPad T41
> Software Environment: Linux n22 2.6.20-gentoo-r7 #4 Sun Apr 29 14:05:29 CEST
> 2007 i686 Intel(R) Pentium(R) M processor 1700MHz GenuineIntel GNU/Linux
> 
> Problem Description:
> I'm wondering why the network packets I got from my ADSL line are ok from the
> ppp0 interface but often have incorrect checksums if I sniff them at the eth0
> interface (using wireshark).
> 
> Although the amount of the affected packets are reduced from kernel version
> 2.6.1[89] to the current kernel the problem still happens at least for all UDP
> Microsoft messenger packets and for some other  TCP packets too.
> 
> The problem can be seen in the 2 attached pcap files I sniffed with tcpdump at
> the same time, the 2 command lines at 2 different terminals were :
> 
> n22 ~ # tcpdump -i eth0 -s 0 -w tcpdump_eth0.pcap 
> n22 ~ # tcpdump -i ppp0 -s 0 -w tcpdump_ppp0.pcap
> 
> Look at packets 2 and 3 of the 2 attached files for the messenger problem and
> for packet 23 in tcpdump_eth0.pcap  respectivly packet 21 in tcpdump_ppp0.pcap
> 
> The 2nd case prevents the KDE application kgpg to return from a search for a
> given gpg key b/c the kde application seems to ignore TCP packets having nota
> correct checksum :-(
> 
> 
> 
> Might be it has something to do with my current firewall configuration (b/c here
>  my reported issue was related rather to the netfilter module than to e1000
> :http://bugzilla.kernel.org/show_bug.cgi?id=7938#c4 )
> 
> These are the modules I'm using:
> n22 ~ # lsmod | grep -e nf_ -e ipt_ -e xt_
> ipt_MASQUERADE          2560  2
> xt_multiport            3136  12
> ipt_REJECT              3392  1
> xt_tcpudp               3264  29
> ipt_recent              7920  6
> nf_conntrack_irc        5732  0
> nf_conntrack_ftp        8288  0
> xt_state                1984  2
> xt_limit                2112  3
> ipt_LOG                 5696  3
> nf_nat                 14444  2 ipt_MASQUERADE,iptable_nat
> nf_conntrack_ipv4      12492  4 iptable_nat
> nf_conntrack           46888  7
> ipt_MASQUERADE,nf_conntrack_irc,nf_conntrack_ftp,xt_state,iptable_nat,nf_nat,nf_conntrack_ipv4
> x_tables               11716  10
> ipt_MASQUERADE,xt_multiport,ipt_REJECT,xt_tcpudp,ipt_recent,xt_state,xt_limit,ipt_LOG,iptable_nat,ip_tables
> 
> 

