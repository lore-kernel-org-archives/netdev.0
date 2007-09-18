From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 12:09:52 -0700
Message-ID: <1190142592.9540.218.camel@dell>
References: <200709181823.26429.vda.linux@googlemail.com>
 <1190141114.9540.216.camel@dell>
 <200709181855.37598.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>
To: "Denys Vlasenko" <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3787 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755308AbXIRSMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 14:12:30 -0400
In-Reply-To: <200709181855.37598.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-18 at 18:55 +0100, Denys Vlasenko wrote:
> On Tuesday 18 September 2007 19:45, Michael Chan wrote:
> > We can compress all the different sections of the firmware.  Currently,
> > we only compress the biggest chunks and the rest are uncompressed.
> 
> > These zeros should compress to almost nothing.  But I agree that the
> > firmware is still big.
> 
> You don't need to store and fetch zeros at all. You *know* that
> they are zeros, right? So do this:
> 
> -                         REG_WR_IND(bp, offset, fw->bss[j]);
> +                         REG_WR_IND(bp, offset, 0);
> 
Good point.  We can do that.  Looking at the file, there are other non-
zero data that can be compressed to save some more room.

