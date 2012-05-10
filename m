From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: Re: cxgb4 mbox4 errors listening to multiple multicast addresses
Date: Thu, 10 May 2012 15:57:49 -0500
Message-ID: <20120510205749.GB4709@BohrerMBP.rgmadvisors.com>
References: <20120510201408.GA4709@BohrerMBP.rgmadvisors.com>
 <4FAC2941.5080301@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:35519 "EHLO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757431Ab2EJVFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 17:05:03 -0400
Received: by mail-yw0-f41.google.com with SMTP id 47so2812954yhr.14
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 14:05:02 -0700 (PDT)
In-Reply-To: <4FAC2941.5080301@chelsio.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 10, 2012 at 01:46:57PM -0700, Dimitris Michailidis wrote:
> On 05/10/2012 01:14 PM, Shawn Bohrer wrote:
> >Is there any translation of those cryptic mbox 4 errors?
> 
> The mbox messages are dumps of mailbox commands that try to register
> MAC addresses and fail due to exhaustion of exact MAC filters.  It
> should fall back to ALL_MULTI mode and probably shouldn't be logging
> these as they are expected failure.  From your description it would
> appear it didn't fall back, I'll take a closer look.  Can you send
> me the output of ifconfig or ip link for the port in this state?

$ ifconfig eth6
eth6      Link encap:Ethernet  HWaddr 00:07:43:10:52:B0  
          inet6 addr: fe80::207:43ff:fe10:52b0/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7811818 errors:0 dropped:0 overruns:0 frame:0
          TX packets:9087 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1171756876 (1.0 GiB)  TX bytes:608182 (593.9 KiB)
          Interrupt:38 

$ ifconfig vlan824
vlan824   Link encap:Ethernet  HWaddr 00:07:43:10:52:B0  
          inet addr:10.8.24.40  Bcast:10.8.31.255  Mask:255.255.248.0
          inet6 addr: fe80::207:43ff:fe10:52b0/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7811450 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8895 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:999858056 (953.5 MiB)  TX bytes:409410 (399.8 KiB)

$ ip link show eth6
6: eth6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:07:43:10:52:b0 brd ff:ff:ff:ff:ff:ff

$ ip link show vlan824
11: vlan824@eth6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 00:07:43:10:52:b0 brd ff:ff:ff:ff:ff:ff


--
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.
