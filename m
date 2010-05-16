From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system
 (2.6.33.3)
Date: Sun, 16 May 2010 11:51:45 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B78147539@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <alpine.LNX.1.10.1005161511490.6004@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Krzysztof Oledzki'" <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1132 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754210Ab0EPSvx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 14:51:53 -0400
In-Reply-To: <alpine.LNX.1.10.1005161511490.6004@bizon.gios.gov.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki wrote:

>
> Why the driver registers 5 interrupts instead of 4? How to
> limit it to 4?
>

The first vector (eth0-0) handles link interrupt and other slow
path events.  It also has an RX ring for non-IP packets that are
not hashed by the RSS hash.  The majority of the rx packets should
be hashed to the rx rings eth0-1 - eth0-4, so I would assign these
vectors to different CPUs.

