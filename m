From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 15 Jun 2006 23:47:11 -0600
Message-ID: <20060616054711.GA28524@colo.lackof.org>
References: <44883778.8000209@pobox.com> <20060608170120.GI8246@colo.lackof.org> <20060613235531.GA4191@colo.lackof.org> <448F5952.1060201@pobox.com> <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com> <20060614181419.GA10365@colo.lackof.org> <20060614204720.GA17887@electric-eye.fr.zoreil.com> <20060614223021.GB13212@colo.lackof.org> <20060615203017.GA6724@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:10948 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S1750749AbWFPFrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2006 01:47:13 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060615203017.GA6724@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 15, 2006 at 10:30:17PM +0200, Francois Romieu wrote:
> Afaik free_irq() on a shared irq does not touch the hardware and
> irqs are anything but synchronous. If free_irq() is issued before
> the device is idle and its irq are not acked, it's wrong.

Correct. Before calling free_irq(), patch V3 masks interrupts on tulip
and guarantees the tulip will not generate new interrupts before that call.

grant
