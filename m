From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Thu, 20 Aug 2015 13:53:07 +0200
Message-ID: <20150820135307.3ce12f69@griffin>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>
	<1439966648-26195-1-git-send-email-vincent@bernat.im>
	<1439966648-26195-2-git-send-email-vincent@bernat.im>
	<20150819130013.1a847627@griffin>
	<87bne38oj7.fsf@zoro.exoscale.ch>
	<20150819143800.6863fa3b@griffin>
	<8737zf8mwd.fsf@zoro.exoscale.ch>
	<55D4AFCA.7080300@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vincent Bernat <vincent@bernat.im>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203AbbHTLxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2015 07:53:10 -0400
In-Reply-To: <55D4AFCA.7080300@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2015 18:33:14 +0200, Nicolas Dichtel wrote:
> Probably better to introduce veth netlink attribute then, something like
> IFLA_VETH_PEER and keeps IFLA_LINK_NETNSID.

I'd prefer IFLA_PEER. More generic attribute will be helpful should we
introduce an interface similar to veth in the future.

Also, I'd not combine IFLA_LINK_NETNSID with IFLA_PEER. There might
very well be an interface in the future that will need both IFLA_LINK and
IFLA_PEER and this would just create a confusion. It may be unlikely
but the attributes are cheap and it doesn't make sense to design uAPI
in a way that might bring problems in the future.

> I also don't know what is the best way to handle this. veth advertises
> its peer via IFLA_LINK since 4.1, so it's too late to change it for this
> release.

Apparently we need to pick our poison. Either way, we break something.

 Jiri

-- 
Jiri Benc
