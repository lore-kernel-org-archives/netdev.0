From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Tue, 24 Mar 2015 22:50:47 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250274F2A@FMSMSX105.amr.corp.intel.com>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
 <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com>
 <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com>
 <55113B9B.3090308@cloudius-systems.com>
 <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com>
 <5511AFD6.2020406@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4245 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469AbbCXWuu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:50:50 -0400
In-Reply-To: <5511AFD6.2020406@cloudius-systems.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com] 
>Sent: Tuesday, March 24, 2015 11:41 AM
>To: Tantilov, Emil S; netdev@vger.kernel.org
>Cc: Kirsher, Jeffrey T; avi@cloudius-systems.com; gleb@cloudius-systems.com
>Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
>
>
>
>>On 03/24/15 20:12, Tantilov, Emil S wrote:
>>BTW - there are other issues with your patches. The indirection table seems to come out as all 0s and the VF driver reports link down/up when querying it.
>
>Worked just fine to me on x540.
>What is your setup? How did u check it? Did u remember to patch "ip" tool and enable the querying?

The issue with the link is that you do not have proper locking when calling the mailbox which is messing up the link check subtask. Basically you need to protect the calls to ixgbevf_get_rss_key and get_reta with the mbx_lock similar to how the driver does it in all cases where the mailbox is called. 

Thanks,
Emil
