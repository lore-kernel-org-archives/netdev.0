From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH 3/8] ethoc: enable interrupts after napi_complete
Date: Wed, 24 Nov 2010 10:45:00 -0800
Message-ID: <AANLkTikF11JbpR3EzfO-gvZ-QdmKT7PBDQL1Mh+TaxUD@mail.gmail.com>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se> <1290606058-26703-4-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Adam Edvardsson <adam.edvardsson@orsoc.se>
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:38583 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab0KXSpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 13:45:23 -0500
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id oAOIjLoK030201
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 10:45:22 -0800
Received: from gyd12 (gyd12.prod.google.com [10.243.49.204])
	by kpbe18.cbf.corp.google.com with ESMTP id oAOIhlDH014219
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 10:45:20 -0800
Received: by gyd12 with SMTP id 12so29861gyd.34
        for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 10:45:20 -0800 (PST)
In-Reply-To: <1290606058-26703-4-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethoc_rx can return a value == budget
if work_done == budget, interrupt
are not re-enabled

in net_rx_action, the check for budget <= 0 will
cause the poll loop to not be called, but will removed
the callback to be removed from the poll_list.

could this result in interrupt not being re-enabled ?
