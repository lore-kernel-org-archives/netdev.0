From: Sven Ulland <sveniu@opera.com>
Subject: Re: Route flagged RTCF_REDIRECTED without ICMP redirs?
Date: Fri, 14 Oct 2011 09:15:48 +0200
Message-ID: <4E97E1A4.9080703@opera.com>
References: <20111013185015.fa2abpjlpw8c0408@staff.opera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opera.com ([213.236.208.81]:33780 "EHLO smtp.opera.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319Ab1JNHPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 03:15:51 -0400
Received: from [10.20.18.128] (pat-tdc.opera.com [213.236.208.22])
	(authenticated bits=0)
	by smtp.opera.com (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id p9E7FmQa030982
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 07:15:48 GMT
In-Reply-To: <20111013185015.fa2abpjlpw8c0408@staff.opera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2011 08:50 PM, sveniu@opera.com wrote:
> How can a route end up with being flagged with RTCF_REDIRECTED, and
> point to the default gateway, even though it's explicitly set to
> route to another node in the same subnet, in the rpdb and routing
> tables? There is zero trace of icmp redirects, and all redirect
> sysctls have been disabled, and the route cache flushed before every
> test.

This turned out to be due to [1], where the inet peer cache kept
a redirect learned via icmp before accept_redirect and friends were
disabled, so it was propagated to the route cache. Resolved by
a reboot to clean the inet peer cache.

[1]: Commit f39925d:
<URL:https://github.com/torvalds/linux/commit/f39925dbde7788cfb96419c0f092b086aa325c0f>

best regards,
Sven Ulland
