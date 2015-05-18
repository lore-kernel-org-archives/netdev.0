From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: cpsw_ale clobbers learned addresses?
Date: Mon, 18 May 2015 14:42:17 +0530
Message-ID: <5559ACF1.1080903@ti.com>
References: <20150513193816.GA11130@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:52627 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813AbbERJMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 05:12:18 -0400
In-Reply-To: <20150513193816.GA11130@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 14 May 2015 01:08 AM, Richard Cochran wrote:
> 
> It appears to me that cpsw_ale.c will possibly clobber addresses
> learned by the switch.   When adding a new entry, the code reads the
> table until it finds an empty entry.  Then, it writes the new value to
> that same index.  However, nothing prevents the switch from using that
> same index between the read and the write.
> 
> Or am I missing something?
> 

There are chances that driver might overwrite address learnt by hardware
which was learnt between the instance getting free index and writing
table. Though the same software overwritten mac id will be updated on
the next packet received with same mac id.

Once driver updates the ALE table with valid entry hardware wont be
updating.

Regards
Mugunthan V N
