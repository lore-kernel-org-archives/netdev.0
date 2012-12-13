From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 17:56:57 -0500
Message-ID: <50CA5D39.5060003@mojatatu.com>
References: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com> <50C91506.70903@redhat.com> <20121213094719.3a7a9408@nehalam.linuxnetplumber.net> <20121213.140023.2131448980265576282.davem@davemloft.net> <20121213110404.6d662baa@nehalam.linuxnetplumber.net> <50CA37DA.1090905@mojatatu.com> <20121213140218.2c705bb5@nehalam.linuxnetplumber.net> <50CA588F.9040800@mojatatu.com> <20121213143712.6932cb22@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vyasevic@redhat.com,
	or.gerlitz@gmail.com, netdev@vger.kernel.org, mst@redhat.com,
	john.r.fastabend@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:44309 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab2LMW5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 17:57:00 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so2528340iay.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 14:57:00 -0800 (PST)
In-Reply-To: <20121213143712.6932cb22@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-13 05:37 PM, Stephen Hemminger wrote:

>
> You can, run any action before it hits the bridge.

I think you and I have had this discussion before ;->
It works just fine on ingress.


#Add ingress qdisc on br0
tc qdisc add dev br0 ingress
#Add a filter to accept all and count
tc filter add dev br0 parent ffff: protocol ip prio 6 u32 match ip dst 
0/0 flowid 1:16 action ok
#show the stats
root@jhs12:~# tc -s filter show parent ffff: dev br0
filter protocol ip pref 6 u32
filter protocol ip pref 6 u32 fh 800: ht divisor 1
filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0 
flowid 1:16
   match 00000000/00000000 at 16
	action order 1: gact action pass
	 random type none pass val 0
	 index 2 ref 1 bind 1 installed 269 sec used 74 sec
  	Action statistics:
	Sent 1210 bytes 15 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0
------

Look at those packets ...

cheers,
jamal

cheers,
jamal
