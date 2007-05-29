From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH 2/7] cxgb3 - fix netpoll hanlder
Date: Tue, 29 May 2007 16:59:07 -0700
Message-ID: <465CBE4B.9070009@goop.org>
References: <20070526225952.12115.30971.stgit@localhost.localdomain> <465B591B.1010507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:59587 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040AbXE2X7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 19:59:07 -0400
In-Reply-To: <465B591B.1010507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
>>
>> +        t3_intr_handler(adapter, qs->rspq.polling) (0,
>> +                    (adapter->flags & USING_MSIX) ?
>> +                    (void *)qs : (void *)adapter);
>
> Remove needless casts to void*
The two branches of ?: need to have the same type; without the casts
they'd be "struct sge_qset" and "struct adapter".  Seems a bit cruddy to
have two types passed to one function depending on the MSI state, but
maybe that's OK.

    J
