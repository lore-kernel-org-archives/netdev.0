From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/3] ibmvnic: Enable scatter-gather support
Date: Wed, 18 Oct 2017 11:04:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD009AA16@AcuExch.aculab.com>
References: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <1508261816-3145-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Thomas Falcon' <tlfalcon@linux.vnet.ibm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:62541 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751705AbdJRLE6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:04:58 -0400
In-Reply-To: <1508261816-3145-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon
> Sent: 17 October 2017 18:37
> This patch enables scatter gather support. Since there is no
> HW/FW scatter-gather support at this time, the driver needs to
> loop through each fragment and copy it to a contiguous, pre-mapped
> buffer entry.
...
>  	offset = index * adapter->req_mtu;
>  	dst = tx_pool->long_term_buff.buff + offset;

You should be able to treat the pre-allocated data area as a
big ring buffer.
So it can hold a lot of small frames or a few big ones.
This slightly complicates the 'is there enough space for
this packet' check since you need buffer space as well
as a ring entry.

You also really want to align each tx buffer on a 4n+2
boundary so that most of the copy is aligned.

>  	memset(dst, 0, adapter->req_mtu);
Seems unnecessary.

	David
