From: Wolfgang Nothdurft <Wolfgang.Nothdurft@linogate.de>
Subject: Re: 2.4.35-pre1: new e1000 driver breaks old hardware
Date: Tue, 19 Jun 2007 12:30:02 +0200
Message-ID: <4677B02A.9020804@linogate.de>
References: <46723F39.1000808@linogate.de> <4672B5FD.7070304@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linogate.de ([213.179.141.2]:3335 "EHLO mail.linogate.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755739AbXFSKa2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 06:30:28 -0400
Received: from riab.mowin.de (support.linogate.de [213.179.141.14] (may be forged))
	by mail.linogate.de with ESMTP id l5JAUOAD023166
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 12:30:24 +0200
Received: from [192.168.0.163] ([192.168.0.163])
	by riab.mowin.de with ESMTP id l5JAU7ir003611
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 12:30:08 +0200
In-Reply-To: <4672B5FD.7070304@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Wolfgang Nothdurft wrote:
>> Hi,
>>
>> with the new e1000 driver version 7.3.20 the onboard gigabit nic 82547EI
>> (8086:1019) doesn't work correctly.
>> After transferring about 100 megabytes over a gigabit link the transfer
>> stopped and I have to reinit the link either by doing a ifconfig down/up
>> or unplugging the network cable.
>> The RxIntDelay is set to 0 like described in the docu. Playing with this
>> Parameter only increases the amount of traffic to be send and the error
>> occurs later.
> 
> have you tried (the default) 8000 ? Do you get the same problem when you
> run 2.6.21 with 7.5.5.1 or 7.3.20 ?

With 8000 I can delay the issue, but I thought the default is 0. When I
use out of range values the defaults shown are:

Intel(R) PRO/1000 Network Driver - version 7.3.20-k4
Copyright (c) 1999-2006 Intel Corporation.
PCI: Setting latency timer of device 02:01.0 to 64
e1000: 02:01.0: e1000_validate_option: Invalid Transmit Interrupt Delay
value specified (100000) using default of 8
e1000: 02:01.0: e1000_validate_option: Invalid Transmit Absolute
Interrupt Delay value specified (100000) using default of 32
e1000: 02:01.0: e1000_validate_option: Invalid Receive Interrupt Delay
value specified (100000) using default of 0
e1000: 02:01.0: e1000_validate_option: Invalid Receive Absolute
Interrupt Delay value specified (100000) using default of 8

With kernel 2.6.21 the problem doesn't occur, so it seems to be a kernel
2.4 specific issue.

> 
>> This happens also with the 7.4.35 and 7.5.5 driver from the intel side.
>> The driver 5.7.6 from kernel 2.4.33.3 and the 6.1.16 from intel works
>> very well on this hardware.
>> Also other gigabit nics we use didn't have this problem.
>> Is this issue already known?
> 
> this is the first time I have heard this issue.
> 
>> Is there any solution yet?
> 
> I'm not that good :)
> 
> Can you file a bugreport on e1000.sf.net and attach the usual (ethtool
> -e, dmesg, ifconfig -a, lspci -vv) debugging output and problem
> description for us? I'll try to see if I can have our labs setup a repro
> case, which might be hard given the adapter type, but we will do our best.

done

> 
> Auke
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Wolfgang Nothdurft                 Wolfgang.Nothdurft@linogate.de
Linogate Internet Technologies     fon: +49 (0)821 - 25 96 - 0
