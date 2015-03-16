From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [next-queue 4/7] ixgbe: enable relaxed ordering for SPARC
Date: Mon, 16 Mar 2015 11:49:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB01420@AcuExch.aculab.com>
References: <1426291248-14739-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1426291248-14739-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:55224 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbCPLu4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 07:50:56 -0400
In-Reply-To: <1426291248-14739-5-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> This patch makes sure that relaxed ordering is not disabled when
> on SPARC, where it helps with performance.
...
>  static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
>  {
> +#ifndef CONFIG_SPARC
>  	u32 regval;
>  	u32 i;
> +#endif

You'd be better off putting:

#ifndef CONFIG_SPARC
#define IXGBE_DISABLE_RELAXED_ORDERING
#endif

much higher up.

Then replacing the #ifndef CONFIG_SPARC with #ifdef IXGBE_DISABLE_RELAXED_ORDERING
in the file itself.

Not that Dave M likes #if's in the body of functions.

	David
