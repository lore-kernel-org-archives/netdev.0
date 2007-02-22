From: "Hua Zhong" <hzhong@gmail.com>
Subject: RE: Linux 2.6 HTB does only work with existing connections
Date: Wed, 21 Feb 2007 18:30:03 -0800
Message-ID: <01df01c75629$5c621c50$152654f0$@com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:41051 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbXBVCaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 21:30:13 -0500
Received: by py-out-1112.google.com with SMTP id a29so16672pyi
        for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 18:30:12 -0800 (PST)
References: 
In-Reply-To: 
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just add more info: this machine has TOE. And if that's turned off,
everything seems to work fine.

Does it mean that traffic control doesn't play well with TOE? Or there are
some tricks to make them work together?

Thanks for any pointers.

BTW: it's x86_64 but I guess it doesn't matter much.

> -----Original Message-----
> From: Hua Zhong [mailto:hzhong@gmail.com]
> Sent: Wednesday, February 21, 2007 5:45 PM
> To: 'netdev@vger.kernel.org'
> Subject: Linux 2.6 HTB does only work with existing connections
> 
> Hi all,
> 
> I tried to use HTB on a 2.6.12 based kernel. It seems that if I issue
> the tc commands, existing connections adjust bandwidth immediately, but
> any new connections won't be filtered correctly.
> 
> The tc version is 3.17.
> 
> The commands are very simple (only eth1 is active):
> 
>     tc qdisc del dev eth1 root
>     tc qdisc add dev eth1 root handle 1: htb default 20
>     tc class add dev eth1 parent 1: classid 1:20 htb rate 4000kbit
> 
> No filters, just limit everything to under 4Mbit.
> 
> Then run ttcp to a remote machine, ifconfig shows eth1 is not limited.
> 
> However, while ttcp is running, issue the above three commands again,
> the bandwidth is then limited correctly.
> 
> Any ideas?
> 
> The following are the show commands:
> 
> # tc qdisc show dev eth1
> qdisc htb 1: r2q 10 default 20 direct_packets_stat 11
> # tc class show dev eth1
> class htb 1:20 root prio 0 rate 4000Kbit ceil 4000Kbit burst 2099b
> cburst 2099b
> 
> Please cc me.
> 
> Hua

