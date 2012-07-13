From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Crash in CIPSO_V4_TAG_LOCAL handling
Date: Fri, 13 Jul 2012 18:08:41 +0100
Message-ID: <20120713180841.2b202cf8@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:33522 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932288Ab2GMRE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 13:04:59 -0400
Received: from pyramind.ukuu.org.uk (earthlight.etchedpixels.co.uk [81.2.110.250])
	by lxorguk.ukuu.org.uk (8.14.5/8.14.1) with ESMTP id q6DHcP2a018178
	for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 18:38:30 +0100
Received: from pyramind.ukuu.org.uk (localhost [127.0.0.1])
	by pyramind.ukuu.org.uk (8.14.5/8.14.5) with ESMTP id q6DH8fZW030043
	for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 18:08:44 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DaveM asked that this goes direct to the list so ...

Looking at some static code analyser output and the results seem valid on
this one:

ip_options_compile called with skb = NULL and an IPOPT_CIPSO option calls
into cipso_v4_validate, which if the option is CIPSO_V4_TAG_LOCAL then
dereferences skb->dev and explodes.

All the other cases appear to correctly avoid or check it versus NULL

Alan
