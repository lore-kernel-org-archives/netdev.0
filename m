From: Andreas Jellinghaus <aj@ciphirelabs.com>
Subject: Re: [ANN] Acrypto asynchronous crypto layer 2.6.19 release.
Date: Mon, 18 Dec 2006 14:00:26 +0100
Message-ID: <458690EA.2000405@ciphirelabs.com>
References: <20061216191521.GA26549@2ka.mipt.ru> <4586458E.6000503@dungeon.inka.de> <20061218095740.GA5219@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:53114 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005AbWLROGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 09:06:22 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GwI6z-0004O9-Ot
	for netdev@vger.kernel.org; Mon, 18 Dec 2006 14:00:57 +0100
Received: from ciphirelabs.net ([217.72.114.248])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 18 Dec 2006 14:00:57 +0100
Received: from aj by ciphirelabs.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 18 Dec 2006 14:00:57 +0100
To: netdev@vger.kernel.org
In-Reply-To: <20061218095740.GA5219@2ka.mipt.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Actually I do not recall what is 'size retrictions' - if you talk about
> possibility to use software crypto provider, which supports one cipher
> in a time, then yes, but it is intended to be used with hardware though.
> Otherwise I do not recall any problems pointed to me.

sorry, "size restriction" was the wrong term. acrypto only supports
"sync provider only supports AES-128 in CBC mode, so if you try
different ciphers, there can be some problems."

and I'm using dm-crypto with aes-cbc-essiv:sha256 and your acrypto patch
breaks this setup - not only acrypto doesn't provide crypto capability 
for my setup, but with this patch it is not offered by the old mechanism
either, so my system has no way to decrypt the root partition. note:
that was with the 2.6.18 patch, no idea if it is different now.

so while the patch adds new features, it also removes some features -
not sure if always (via patch) or via compile option or via module
load. also I'm not sure if acrypto can be disabled via kernel command
line to get the old behaviour (including aes-cbc-essiv:sha256 support
for dm-crypt).

would be nice to track those issues, so people testing your patch
are aware of the situation.

Regards, Andreas

