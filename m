From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 2/6] bnx2x: protect different statistics flows
Date: Mon, 05 Aug 2013 16:26:18 -0700 (PDT)
Message-ID: <20130805.162618.882986953709212779.davem@davemloft.net>
References: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
	<1375738544-8695-3-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239Ab3HEX0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 19:26:19 -0400
In-Reply-To: <1375738544-8695-3-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 6 Aug 2013 00:35:40 +0300

> Add locking to protect different statistics flows from
> running simultaneously.
> This in order to serialize statistics requests sent to FW,
> otherwise two outstanding queries may cause FW assert.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Please do not reinvent the wheel, use a standard semaphore
and down_timeout().

Anytime you feel that you have to implement your own fancy locking
primitives, you are doing it wrong.
