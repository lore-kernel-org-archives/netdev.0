From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [RFC PATCH net-next] bonding: Use notifiers for slave link
 state detection
Date: Wed, 13 Jan 2016 17:03:17 +0000
Message-ID: <87618083B2453E4A8714035B62D679925050766D@FMSMSX105.amr.corp.intel.com>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
 <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
 <16587.1452148421@famine> <27321.1452216515@famine>
 <87618083B2453E4A8714035B62D6799250505491@FMSMSX105.amr.corp.intel.com>
 <11809.1452305978@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"mkubecek@suse.cz" <mkubecek@suse.cz>,
	"vfalico@gmail.com" <vfalico@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:12899 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754293AbcAMRDT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 12:03:19 -0500
In-Reply-To: <11809.1452305978@famine>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jay Vosburgh [mailto:jay.vosburgh@canonical.com]
>Sent: Friday, January 08, 2016 6:20 PM
>To: Tantilov, Emil S
>Cc: zyjzyj2000@gmail.com; mkubecek@suse.cz; vfalico@gmail.com;
>gospo@cumulusnetworks.com; netdev@vger.kernel.org; Shteinbock, Boris (Wind
>River)
>Subject: Re: [RFC PATCH net-next] bonding: Use notifiers for slave link
>state detection
>
>Tantilov, Emil S <emil.s.tantilov@intel.com> wrote:
>
>>>-----Original Message-----
>>From: Jay Vosburgh [mailto:jay.vosburgh@canonical.com]
>>>Sent: Thursday, January 07, 2016 5:29 PM
>>>Subject: [RFC PATCH net-next] bonding: Use notifiers for slave link state
>>>detection
>>>
>>>
>>>	TEST PATCH
>>>
>>>	This patch modifies bonding to utilize notifier callbacks to
>>>detect slave link state changes.  It is intended to be used with miimon
>>>set to zero, and does not support the updelay or downdelay options to
>>>bonding.  It's not as complicated as it looks; most of the change set is
>>>to break out the inner loop of bond_miimon_inspect into its own
>>>function.
>>
>>Jay,
>>
>>I managed to do a quick test with this patch and occasionally there is
>>a case where I see the bonding driver reporting link up for an
>>interface (eth1) that is not up just yet:
>[...]
>>[12985.213752] ixgbe 0000:01:00.0 eth0: NIC Link is Up 10 Gbps, Flow
>Control: RX/TX
>>[12985.213970] bond0: link status definitely up for interface eth0, 10000
>Mbps full duplex
>>[12985.213975] bond0: link status definitely up for interface eth1, 0 Mbps
>full duplex
>
>	Thanks for testing; the misbehavior is because I cheaped out and
>didn't break out the commit function into a "single slave" version.  The
>below patch (against net-next, replacing the original patch) shouldn't
>generate the erroneous additional link messages any more.
>
>	This does generate an RCU warning, although the code actually is
>safe (since the notifier callback holds RTNL); I'll sort that out next
>week.
>
>	-J

Alright, so I was able to kick off another test with this patch and it's
been running for 24 hours+ without errors. The setup I have has all kinds of
link issues, so it's a pretty good stress test.

Note that the issue that started this thread was due to the ixgbe driver 
reporting speed directly from the LINKS register, which is no longer the case,
so just using notifiers is probably not enough to get around this issue, but
this should not be a problem anymore (at least for ixgbe).

Thanks,
Emil
