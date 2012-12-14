From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Fri, 14 Dec 2012 11:50:51 -0500
Message-ID: <50CB58EB.9050302@redhat.com>
References: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com> <50C91506.70903@redhat.com> <20121213094719.3a7a9408@nehalam.linuxnetplumber.net> <20121213.140023.2131448980265576282.davem@davemloft.net> <20121213110404.6d662baa@nehalam.linuxnetplumber.net> <50CA37DA.1090905@mojatatu.com> <20121213140218.2c705bb5@nehalam.linuxnetplumber.net> <50CA588F.9040800@mojatatu.com> <20121213143712.6932cb22@nehalam.linuxnetplumber.net> <50CA5D39.5060003@mojatatu.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, or.gerlitz@gmail.com,
	netdev@vger.kernel.org, mst@redhat.com, john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756224Ab2LNQu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 11:50:57 -0500
In-Reply-To: <50CA5D39.5060003@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/13/2012 05:56 PM, Jamal Hadi Salim wrote:
> On 12-12-13 05:37 PM, Stephen Hemminger wrote:
>
>>
>> You can, run any action before it hits the bridge.
>
> I think you and I have had this discussion before ;->
> It works just fine on ingress.
>
>
> #Add ingress qdisc on br0
> tc qdisc add dev br0 ingress
> #Add a filter to accept all and count
> tc filter add dev br0 parent ffff: protocol ip prio 6 u32 match ip dst
> 0/0 flowid 1:16 action ok
> #show the stats
> root@jhs12:~# tc -s filter show parent ffff: dev br0
> filter protocol ip pref 6 u32
> filter protocol ip pref 6 u32 fh 800: ht divisor 1
> filter protocol ip pref 6 u32 fh 800::800 order 2048 key ht 800 bkt 0
> flowid 1:16
>    match 00000000/00000000 at 16
>      action order 1: gact action pass
>       random type none pass val 0
>       index 2 ref 1 bind 1 installed 269 sec used 74 sec
>       Action statistics:
>      Sent 1210 bytes 15 pkt (dropped 0, overlimits 0 requeues 0)
>      backlog 0b 0p requeues 0
> ------
>
> Look at those packets ...

Interesting.  But, but how complex would be be to configure a vlan 
filter for say 10 different vlans, each one of them only permitted
to be forwarded to their respective VM.  Oh, and Vlan tags should
be stripped when they are being forwarded.

config:
       +- eth0
       |
   br0-+- vnet0 (vlan10) - VM1
       |
       +- vnet1 (vlan20) - VM2
       |
       +- vnet3 (vlan30) - VM3
... etc...

-vlad
>
> cheers,
> jamal
>
> cheers,
> jamal
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
