From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 18:55:37 +0100
Message-ID: <200709181855.37598.vda.linux@googlemail.com>
References: <200709181823.26429.vda.linux@googlemail.com> <1190141114.9540.216.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:42779 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071AbXIRRzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 13:55:47 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1667151wxd
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 10:55:46 -0700 (PDT)
In-Reply-To: <1190141114.9540.216.camel@dell>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 September 2007 19:45, Michael Chan wrote:
> We can compress all the different sections of the firmware.  Currently,
> we only compress the biggest chunks and the rest are uncompressed.

> These zeros should compress to almost nothing.  But I agree that the
> firmware is still big.

You don't need to store and fetch zeros at all. You *know* that
they are zeros, right? So do this:

-                         REG_WR_IND(bp, offset, fw->bss[j]);
+                         REG_WR_IND(bp, offset, 0);

--
vda
