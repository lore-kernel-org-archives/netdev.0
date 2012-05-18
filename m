From: "Robin H. Johnson" <robbat2@gentoo.org>
Subject: Docs bug or argument handling error in iproute2 xt action
Date: Fri, 18 May 2012 18:16:58 +0000
Message-ID: <robbat2-20120518T180852-646570714Z@orbis-terrarum.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:57304 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932754Ab2ERSRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2012 14:17:00 -0400
Received: from grubbs.orbis-terrarum.net (localhost [127.0.0.1])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTPS id 5E12B1B400B
	for <netdev@vger.kernel.org>; Fri, 18 May 2012 18:16:59 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Please CC, not subscribed to netdev)

>From doc/actions/ifb-README in the iproute2 repo:
===================
# redirect all IP packets arriving in eth0 to ifb0
# use mark 1 --> puts them onto class 1:1
$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action ipt -j MARK --set-mark 1 \
action mirred egress redirect dev ifb0
===================

Other documentation says 'ipt' has been replaced by 'xt',
but the passing of arguments other than the jump target doesn't seem to work at all with xt.

Running the above with s/ipt/xt/ gets me:
====
xt: unrecognized option '--set-mark'
Killed
====

-- 
Robin Hugh Johnson
Gentoo Linux: Developer, Trustee & Infrastructure Lead
E-Mail     : robbat2@gentoo.org
GnuPG FP   : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85
