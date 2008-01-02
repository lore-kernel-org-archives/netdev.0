From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Section mismatch between 'copy_net_ns' and 'net_enable_timestamp
Date: Wed, 02 Jan 2008 15:28:00 +0100
Message-ID: <477B9F70.5000709@fr.ibm.com>
References: <147a89290801020616g310fff86t6c8d34d32df3865a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Johnson <johnsonzjo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:1566 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbYABOg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 09:36:26 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m02EaP4B158428
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 14:36:25 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m02EaPdI1654888
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 14:36:25 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m02EaIvM022935
	for <netdev@vger.kernel.org>; Wed, 2 Jan 2008 14:36:19 GMT
In-Reply-To: <147a89290801020616g310fff86t6c8d34d32df3865a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Johnson wrote:
> Hello,
>  I had git-cloned the net-2.6.25.git tree today;
> 
>  Then I ran "make menuconfig" and accepted the defaults without any change.
> I want to build this tree with network namespace support.
> I saw that in 2.6.25/net/core/net_namespace.c
> we have some #ifdef CONFIG_NET_NS ; I did not CONFIG_NET_NS in "make
> menuconfig".
> So I added in net_namespace.c #define CONFIG_NET_NS, before the first
> #ifdef CONFIG_NET_NS; then I ran make.
> 
> I saw the following warning:
> 
> WARNING: vmlinux.o(.text+0x1d47cd): Section mismatch: reference to .init.text:
> (between 'copy_net_ns' and 'net_enable_timestamp')
> 
> 
> Is there something wrong here causing this "Section mismatch"?
> or did I do something wrong?
> 
> Regards,
> Andy
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Hi Andy,

If you want to activate the network namespace, you should disable the 
sysfs. This is a temporary restriction until Greg-KH integrates the 
sysfs per namespace:

https://lists.linux-foundation.org/pipermail/containers/2007-December/009347.html

Can you try to using the menuconfig to enable the network namespace and 
check if you still have the section mismatch ?

General setup
  -> Prompt for development and/or incomplete code/drivers => enable
  -> Configure standard kernel features => enable

File systems
  -> Pseudo filesystems
   -> sysfs file system support => disable

Networking
  -> Networking options
   -> Network namespace support => enable

Thanks
   -- Daniel
