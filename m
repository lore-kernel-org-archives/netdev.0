From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2, 2.6.29, smp_affinity strangeness
Date: Thu, 2 Apr 2009 22:26:26 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421666854D2A@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <200903290447.58338.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: "'Denys Fedoryschenko'" <denys@visp.net.lb>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4598 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751877AbZDCF0j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 01:26:39 -0400
In-Reply-To: <200903290447.58338.denys@visp.net.lb>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote:

> While running bnx2 tried to assign affinity to network card
> and ... failed.
>

This is a known problem on the 5708 card that does not support
MSI per vector masking.  On the 5708 NIC, the new MSI address/
data will only take effect after MSI has been disabled and
re-enabled.

The IRQ migration code in the kernel no longer disables the MSI
on devices that don't support per masking before IRQ migration.
As a result, changing IRQ affinity will not work after the device
is initialized.  You can force a reset, (by doing some ethtool
operation for example), after you change the affinity and it should
work.

