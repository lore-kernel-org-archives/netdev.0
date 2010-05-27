From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: bnx2: Fix uninitialized variable warning in
 bnx2_disable_forced_2g5()
Date: Thu, 27 May 2010 16:26:33 -0700 (PDT)
Message-ID: <20100527.162633.39169784.davem@davemloft.net>
References: <20100527220856.25418.86593.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41359
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754418Ab0E0X0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 19:26:23 -0400
In-Reply-To: <20100527220856.25418.86593.sendpatchset@prarit.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prarit Bhargava <prarit@redhat.com>
Date: Thu, 27 May 2010 18:13:01 -0400

> Fix warning:
> 
> drivers/net/bnx2.c: In function 'bnx2_disable_forced_2g5':
> drivers/net/bnx2.c:1489: warning: 'bmcr' may be used uninitialized in this function
> 
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>

This is another bad patch, you're hiding a bug by making this warning
go away.

If bnx2_read_phy() in fact does not initialize "bmcr" we might
want to do something about that instead of just blindly using
whatever garbage is in that local variable.

Please stop making these patches without applying at least some
intelligence to the analysis of why these warnings are being
printed at all.

None of these cases you're posting patches for are situations where
the compiler simply can't see the control flow properly, they are real
issues.

Thanks.
