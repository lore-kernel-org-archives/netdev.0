From: "Benjamin Li" <benli@broadcom.com>
Subject: Re: Broadcom 5709 take long time to bring up
Date: Wed, 18 Aug 2010 09:08:55 -0700
Message-ID: <1282147735.3880.83.camel@localhost>
References: <20100818143432.GA29386@joejin-pc.cn.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>,
	"terry.liu@oracle.com" <terry.liu@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Joe Jin" <joe.jin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3237 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753783Ab0HRQJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 12:09:14 -0400
In-Reply-To: <20100818143432.GA29386@joejin-pc.cn.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

Just a couple of quick questions:

1.  It is possible that autonegotiation could take in the orders of
seconds depending on the remote partner.   Could you describe the remote
partner?

2.  Are there iSCSI offload connections?  With iSCSI there is
additionial overhead to cleanup/setup iSCSI connections on the
chip/firmware when ifup'ing/ifdown'ing a network interface.

3.  Could you provide the kernel logs during this up/down test?  I
wanted to see if there was anything interesting in the kernel logs.

Thanks again.

-Ben


On Wed, 2010-08-18 at 07:34 -0700, Joe Jin wrote:
> Hi Michael,
> 
> We try boning two broadcom 5709 nics with active-backup mode, we try to
> down/up one of the nics, I found some ping packets loss as below:
> # ifdown eth0 
> # ifup eth0  <-- no pkg loss 
> # ifdown eth1 
> # ifup eth1  <-- 2 pkg loss 
> # ifdown eth0 
> # ifup eth0  <-- 10 pkg loss 
> # ifdown eth1 
> # ifup eth1 <-- no pkg loss 
> # ifdown eth0 
> # ifup eth0  <-- 10 pkg loss 
> 
> module bond parameter are:
> "mode=1 miimon=100 primary=eth0 downdelay=100 updelay=100"
> 
> we have tried the latest driver(2.0.8c) of broadcom and Redhat el5.5
> official driver(2.0.2), result are same.
> 
> I checked and debugged the driver found it caused by take long time(~3s)
> to bring up the device. here are link state when call if up:
> # ifdown eth0 
> # ifup eth0   
> #ip -o link | grep eth0 
> 2: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
> # ifdown eth1 
> # ifup eth1   
> #ip -o link | grep eth1 
> 3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
> # ifdown eth0 
> # ifup eth0   
> #ip -o link | grep eth0 
> 2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
> # ifdown eth1 
> # ifup eth1   
> #ip -o link | grep eth1 
> 3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
> # ifdown eth0 
> # ifup eth0 
> #ip -o link | grep eth0 
> 2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
> 
> So, the question is how long alway will take when bring up the interface?
> 3 seconds as expection or no? if not, is that a firmware issure or driver
> issue?
> 
> Thanks,
> Joe
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


