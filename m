From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net] r8169: remove the obsolete and incorrect AMD
 workaround
Date: Thu, 24 Jan 2013 08:09:11 +0200
Message-ID: <20130124080911.31d52da9@vostro>
References: <20130121234205.GA12449@electric-eye.fr.zoreil.com>
	<1358843435-24719-1-git-send-email-timo.teras@iki.fi>
	<20130123000541.GA9515@electric-eye.fr.zoreil.com>
	<20130123081408.2646fc4e@vostro>
	<20130123223834.GA5124@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:64761 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab3AXGJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 01:09:03 -0500
Received: by mail-ee0-f52.google.com with SMTP id b15so4349326eek.39
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 22:09:01 -0800 (PST)
In-Reply-To: <20130123223834.GA5124@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jan 2013 23:38:34 +0100 Francois Romieu
<romieu@fr.zoreil.com> wrote:

> Timo Teras <timo.teras@iki.fi> :
> [...]
> > Actually, this sounds wrong. Why is rtl8169_rx_vlan_tag() which is
> > fiddling opts2 invoked *after* rtl8169_mark_to_asic() ? This means
> > it can overwrite the tag info if the queue is full.
> 
> Yes. It has been there for ages.
> 
> What about something like the patch below ?

Looks good as the minimum intrusion for stable branches. Though, I'm
wondering if it'd be easy to refactor rtl_rx() so that it would
not need that many goto labels.
