From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: NAPI rescheduling and the delay caused by it
Date: Mon, 09 Dec 2013 17:17:40 -0800
Message-ID: <1386638260.30495.339.camel@edumazet-glaptop2.roam.corp.google.com>
References: <529F7A87.5080303@citrix.com>
	 <1386189718.30495.131.camel@edumazet-glaptop2.roam.corp.google.com>
	 <529F9D4B.1020208@citrix.com>
	 <1386199931.30495.139.camel@edumazet-glaptop2.roam.corp.google.com>
	 <6F39C955CEA9D14BAA91CC78568B93012D5039@AMSPEX01CL02.citrite.net>
	 <1386638065.30495.338.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Jonathan Davies <Jonathan.Davies@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f50.google.com ([209.85.128.50]:50787 "EHLO
	mail-qe0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab3LJBRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:17:44 -0500
Received: by mail-qe0-f50.google.com with SMTP id 1so3507399qec.23
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 17:17:43 -0800 (PST)
In-Reply-To: <1386638065.30495.338.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-09 at 17:14 -0800, Eric Dumazet wrote:

> > I found another suspect however: my grant mapping patches do the
> > unmapping from the NAPI instance where otherwise we receive the
> > packets from the guest. But this means we call napi_schedule from the
> > zerocopy callback, which can be run by anyone who free up that skb,
> > including an another VIF's RX thread (which actually does the transmit
> > TO the guest). I guess that might be bad.
> 
> Same problem : napi_schedule() is meant to be used from interrupt
> context.
> 

Check commit ec13ee80145ccb95b00e6e610044bbd94a170051
for example.
