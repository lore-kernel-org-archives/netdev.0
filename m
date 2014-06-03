From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are
 probed into the Host
Date: Tue, 3 Jun 2014 16:40:32 +0800
Message-ID: <20140603084032.GA13874@richard>
References: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
 <20140602142947.GB28523@richard>
 <CAErSpo4GNxMMWyfcSnMKp65M6DAVwQkRCTuCbt+sWkOJTVt9Cw@mail.gmail.com>
 <CAJZOPZK94-hZfBtpjFMEd5m1STRxbs-wTYsKB5SoC=zES5XfPg@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	David Miller <davem@davemloft.net>,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Tal Alon <talal@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:60905 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbaFCIkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 04:40:42 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 3 Jun 2014 14:10:39 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 1438C394003E
	for <netdev@vger.kernel.org>; Tue,  3 Jun 2014 14:10:37 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s538fJLo56754272
	for <netdev@vger.kernel.org>; Tue, 3 Jun 2014 14:11:19 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s538eYWR000392
	for <netdev@vger.kernel.org>; Tue, 3 Jun 2014 14:10:36 +0530
Content-Disposition: inline
In-Reply-To: <CAJZOPZK94-hZfBtpjFMEd5m1STRxbs-wTYsKB5SoC=zES5XfPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2014 at 11:15:43AM +0300, Or Gerlitz wrote:
>On Mon, Jun 2, 2014 at 7:10 PM, Bjorn Helgaas <bhelgaas@google.com> wrote:
>> Writing a driver is not an empirical process of trying things to see
>> what works.  You need to actively design a consistent structure so you
>> know why and when things are safe.  I object to gratuitous "dev ==
>> NULL" checks because often they are just a way of patching up a driver
>> design that isn't well thought-out.
>
>Bjorn, 1st and most -- Agreed.
>
>Next, to be precise, the use case of rebooting the host while the
>driver was loaded in SRIOV mode and NO VFs probed to VMs worked before
>commit befdf89 and is now broken.
>
>Reading further your response, I understand that the code was probably
>using a sort of hackish branching to make that to happen, and you
>suggest we re-write that section properly so it can serve well when
>(hopefully soon) implemenet
>sriov_configure and possibly also suspend/resume, point taken.
>
>Dave, as for this patch, again, the regression of inability to reboot
>the host node
>while the driver is loaded exists in the latest upstream code as of
>befdf89 / 3.15-rc1
>
>Now, taking into account that 3.15 is after rc8 and the IL devel team
>has a holiday this week, I don't see us coming in time with a more
>deeper fix for 3.15, so maybe you can eventaully go and merge this one
>liner for 3.15?

I am glad to verify your patch, if you wish.

>
>Or.
>
>
>> As I wrote before:
>>   From the PCI core's perspective, after .probe() returns successfully,
>>   we can call any driver entry point and pass the pci_dev to it, and
>>   expect it to work.  Doing mlx4_remove_one() in mlx4_pci_err_detected()
>>   sort of breaks that assumption because you clear out pci_drvdata().
>>   Right now, the only other entry point mlx4 really implements is
>>   mlx4_remove_one(), and it has a hack that tests whether pci_drvdata()
>>   is NULL.  But that's ... a hack, and you'll have to do the same
>>   if/when you implement suspend/resume/sriov_configure/etc.

-- 
Richard Yang
Help you, Help me
