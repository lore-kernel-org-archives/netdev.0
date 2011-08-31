From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 31 Aug 2011 17:51:20 +0200
Message-ID: <20110831175120.739bd5c2@alice>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
	<201108311501.39936.vladz@broadcom.com>
	<20110831155324.7554d035@alice>
	<201108311807.53767.vladz@broadcom.com>
	<20110831173749.60649b50@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Vlad Zolotarov" <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756361Ab1HaPvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 11:51:25 -0400
In-Reply-To: <20110831173749.60649b50@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Aug 2011 17:37:49 +0200 Michal Schmidt wrote:
> I could restore dev->features before
> returning if bnx2x_reload_if_running() fails.

Or even safer - restore them always:
	...
	u32 orig_features = dev->features;
	dev->features = features;
        ret = bnx2x_reload_if_running(dev);
        dev->features = orig_features;
        return ret;
	...
This way we don't have to assume anything about
__netdev_update_features().

Michal
