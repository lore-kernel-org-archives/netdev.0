From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Wed, 19 Aug 2015 13:00:13 +0200
Message-ID: <20150819130013.1a847627@griffin>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>
	<1439966648-26195-1-git-send-email-vincent@bernat.im>
	<1439966648-26195-2-git-send-email-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751786AbbHSLAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 07:00:16 -0400
In-Reply-To: <1439966648-26195-2-git-send-email-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2015 08:44:08 +0200, Vincent Bernat wrote:
> While the documentation doesn't say exactly what kind of relationship
> iflink should represent, until a45253, only lower devices were
> advertised this way. While veth cannot have a lower device, using iflink
> to advertise the peer may create infinite loops in programs using iflink
> to discover device topology.
> 
> Instead of advertising the peer link with iflink, a symbolic link "peer"
> is added to each peer.

By removing veth_get_iflink, you're also stopping IFLA_LINK being
advertised in netlink messages, which consequently makes impossible to
reliably match veth peers across name spaces again. This would be a
huge step backwards.

 Jiri

-- 
Jiri Benc
