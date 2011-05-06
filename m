From: Scott Goldman <scottjg@vmware.com>
Subject: RE: [Pv-drivers] [PATCH] vmxnet3: Consistently disable irqs when
 taking adapter->cmd_lock
Date: Fri, 6 May 2011 13:10:29 -0700
Message-ID: <F78BCF638F95D74A99D036114107EDB5028EFAA0F8@EXCH-MBX-3.vmware.com>
References: <1304706773-21348-1-git-send-email-roland@kernel.org>
 <alpine.LRH.2.00.1105061206500.26660@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Shreyas Bhatewara <sbhatewara@vmware.com>,
	Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:44152 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753185Ab1EFUKa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2011 16:10:30 -0400
In-Reply-To: <alpine.LRH.2.00.1105061206500.26660@sbhatewara-dev1.eng.vmware.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> On Fri, 6 May 2011, Roland Dreier wrote:
> 
> > From: Roland Dreier <roland@purestorage.com>
> >
> > Using the vmxnet3 driver produces a lockdep warning because
> 
> > Signed-off-by: Roland Dreier <roland@purestorage.com>
> 
> 
> Roland, thanks for the analysis and the patch.
> 
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

Likewise, seems pretty sane to me. The command register operations are only control-path operations and disabling interrupts for the duration is probably not a big deal. Touching the cmd reg will result a VMEXIT, where the guest won't be processing interrupts anyway. 

Signed-off-by: Scott J. Goldman <scottjg@vmware.com>

