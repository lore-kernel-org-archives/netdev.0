From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Disabling XPS for 4.4.0-1+ixgbe+OpenStack VM over a VLAN means
 65% increase in netperf TCP_STREAM
Date: Mon, 8 Feb 2016 10:03:35 -0800
Message-ID: <56B8D877.5000402@hpe.com>
References: <56B3A2D4.1010309@hpe.com>
 <CALx6S36PxgZufhFa4qChPJvW0eb1V_fQoQOH7HHKd4q00taR=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:30958 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932662AbcBHSDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 13:03:38 -0500
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com [15.216.225.54])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 6C872333C
	for <netdev@vger.kernel.org>; Mon,  8 Feb 2016 18:03:37 +0000 (UTC)
In-Reply-To: <CALx6S36PxgZufhFa4qChPJvW0eb1V_fQoQOH7HHKd4q00taR=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2016 11:38 AM, Tom Herbert wrote:
> I'd start with verifying the XPS configuration is sane and then trying
> to reproduce the issue outside of using VMs, if both of those are okay
> then maybe look at some sort of bad interaction with OpenStack
> configuration.

So, looking at bare-iron, I can see something similar but not to the 
same degree (well, depending on which is one's metric of interest I guess):


XPS being enabled for ixgbe here looks to be increasing receive side 
service demand by 30% but there is enough CPU available in this setup 
that it is only a loss of 2.5% or so on throughput.

stack@fcperf-cp1-comp0001-mgmt:~$ grep 87380 xps_on_* | awk 
'{t+=$6;r+=$9;s+=$10}END{print "throughput",t/NR,"recv sd",r/NR,"send 
sd",s/NR}'
throughput 9072.52 recv sd 0.8623 send sd 0.3686
stack@fcperf-cp1-comp0001-mgmt:~$ grep TCPOFO xps_on_* | awk '{sum += 
$NF}END{print "sum",sum/NR}'
sum 1621.1
stack@fcperf-cp1-comp0001-mgmt:~$ grep 87380 xps_off_* | awk 
'{t+=$6;r+=$9;s+=$10}END{print "throughput",t/NR,"recv sd",r/NR,"send 
sd",s/NR}'
throughput 9300.48 recv sd 0.6543 send sd 0.3606
stack@fcperf-cp1-comp0001-mgmt:~$ grep TCPOFO xps_off_* | awk '{sum += 
$NF}END{print "sum",sum/NR}'
sum 173.9

happy benchmarking,

rick jones

raw results at ftp://ftp.netperf.org/xps_4.4.0-1_ixgbe.tgz
