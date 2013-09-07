From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH] bnx2x: avoid atomic allocations during initialization
Date: Sat, 7 Sep 2013 12:07:50 +0300
Message-ID: <CAM8tLiPCUS3_jo4KU1zY9+8wRg08fA0ohH9d+0a4jyC69D9JZg@mail.gmail.com>
References: <1378411989-19775-1-git-send-email-mschmidt@redhat.com>
	<20130906.142735.458916282873797040.davem@davemloft.net>
	<504C9EFCA2D0054393414C9CB605C37F20D90E3D@SJEXCHMB06.corp.ad.broadcom.com>
	<20130907.002952.1951928882694928547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	=?ISO-8859-1?Q?Tereza_Schmidtov=E1?= <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:62516 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878Ab3IGJHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 05:07:51 -0400
Received: by mail-vc0-f174.google.com with SMTP id gd11so2805426vcb.33
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 02:07:50 -0700 (PDT)
In-Reply-To: <20130907.002952.1951928882694928547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 7, 2013 at 7:29 AM, David Miller <davem@davemloft.net> wrote:
> From: "Dmitry Kravkov" <dmitry@broadcom.com>
> Date: Sat, 7 Sep 2013 01:45:10 +0000
>
>> Once you allocated the memory during initialization , you will most
>> probably fail to allocate its replacement during RX handling (on
>> this machine).
>
> Not true, these two events can exist in totally different timeframes
> and totally different memory pressure situations.
As seen from the customers, these allocation fail when system
constantly under memory pressure - like VM environment or 32-bit
platforms

>
> Probe should never fail because of an atomic memory allocation if at
> all possible.
We here are in open() flow, not probe()

>
> You should use sleeping allocations in every possible situation for
> maximum stability, and this absolutely matches the approach taken
> by every other major driver.
Sleeping allocation will be valid only for one ring overlap - it just
delays the issue, not resolving it, after ring overlap ALL of them
will be replaced by allocations from interrupt context. And again if
we, discover issue earlier we can provide system with fully working
networking with very acceptable performance using SW GRO stack.
Instead of having device which drops every TPA/FW_GRO aggregation -
user will not able to ssh :(

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
