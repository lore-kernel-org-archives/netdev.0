From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: time for TCP ECN defaulting to on?
Date: Tue, 4 Nov 2008 22:31:00 -0800
Message-ID: <C27F8246C663564A84BB7AB343977242151F4B18B4@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20081104.215839.132524253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@blueteddy.net" <linux-kernel@blueteddy.net>,
	"daniel.blueman@gmail.com" <daniel.blueman@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3503 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754AbYKEGbN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 01:31:13 -0500
In-Reply-To: <20081104.215839.132524253.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> From: "Michael Chan" <mchan@broadcom.com>
> Date: Tue, 04 Nov 2008 17:16:03 -0800
>
> > I think this is no longer a limitation.  The GSO code will take care
> > of ECN properly if the hardware does not support it when doing TSO.
>
> Hmm, good point, but if that is what happens I don't know if I agree
> with it.
>
> If "take care of ECN" means doing TSO in software, that's in my
> opinion the wrong thing to do.
>
Right, it means TSO will be done in software by the GSO code if
ECE or CWR is set in a TSO frame and the driver indicates that
the hardware cannot segment such packets properly.

This allows TSO and ECN to coexist.  Before this, ECN was always
disabled when TSO was enabled.

Assuming ECE and CWR are set infrequently on TSO frames, we still
benefit from hardware TSO most of the time.  Why is it the wrong
thing to do?


