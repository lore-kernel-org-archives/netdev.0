From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next v2 08/15] ixgbevf: compare total_rx_packets and
 budget in ixgbevf_clean_rx_irq
Date: Fri, 21 Nov 2014 14:59:20 +0000
Message-ID: <87618083B2453E4A8714035B62D67992501A43B7@FMSMSX105.amr.corp.intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1416524953-15161-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6D1C9F648C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49912 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755442AbaKUO7X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 09:59:23 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9F648C@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Laight [mailto:David.Laight@ACULAB.COM]
>Sent: Friday, November 21, 2014 3:08 AM
>To: Kirsher, Jeffrey T; davem@davemloft.net
>Cc: Tantilov, Emil S; netdev@vger.kernel.org;
>nhorman@redhat.com; sassmann@redhat.com;
>jogreene@redhat.com; Alexander Duyck
>Subject: RE: [net-next v2 08/15] ixgbevf: compare
>total_rx_packets and budget in ixgbevf_clean_rx_irq
>
>From: Jeff Kirsher
>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>>
>> total_rx_packets is the number of packets we had cleaned, and budget is
>> the total number of packets that we could clean per poll. Instead of
>> altering both of these values we can save ourselves one write to memory by
>> just comparing total_rx_packets to the budget and as long as we are less
>> than budget we continue cleaning.
>>
>> Also change the do{}while logic to while{} in order to avoid processing
>> packets when budget is 0.
>
>Does it matter if one packet is processed when budget is zero?
>The 'do {} while ();' version will generate better code.

Yes. The change is in sync with other drivers to protect against netpoll:
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/patch/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c?id=57ba34c9b068f314b219affafc19a39f8735d5e8

Thanks,
Emil

>
>	David
>
>
