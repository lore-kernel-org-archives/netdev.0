From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Re: WARNING: at kernel/softirq.c:159 _local_bh_enable_ip+0x35/0x71()
Date: Thu, 23 Feb 2012 11:42:37 +0100
Message-ID: <20120223104237.GA2127@electric-eye.fr.zoreil.com>
References: <1422860.157191329872584374.JavaMail.weblogic@epml01>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jongman Heo <jongman.heo@samsung.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Scott J. Goldman" <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50883 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798Ab2BWKzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 05:55:36 -0500
Content-Disposition: inline
In-Reply-To: <1422860.157191329872584374.JavaMail.weblogic@epml01>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Heo, your mua broke threading)

Jongman Heo <jongman.heo@samsung.com> :
> Francois Romieu<romieu@fr.zoreil.com>
> > > Jongman Heo <jongman.heo@samsung.com> :
> > > Following warning triggered with my VMware Linux guest, when NFS connection is requested from outside.
> > 
> > I'd try reverting 39d4a96fd7d2926e46151adbd18b810aeeea8ec0.
[...]
> I confirm that reverting the commit fixes the warning.

Shreyas, can you provide a proper fix for this bug (see
http://www.spinics.net/lists/netdev/msg189554.html for details).

As far as I understand it you can not claim a fake transport layer header
size for udp and blindly check the available buffer size through
pskb_may_pull later. With a 32 bits HIGHMEM guest config (yuck...) it ends
up enabling bh within a network device start_xmit context.

-- 
Ueimor
