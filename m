From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7716] New: change in behavior of OUTPUT chain
 reject rule in 2.6.19?
Date: Tue, 19 Dec 2006 20:07:58 -0800
Message-ID: <20061219200758.64bf5a81.akpm@osdl.org>
References: <200612200358.kBK3wErN020293@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org,
	maccetta@laurelnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:60896 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964849AbWLTEIU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 23:08:20 -0500
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
In-Reply-To: <200612200358.kBK3wErN020293@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Dec 2006 19:58:14 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7716
> 
>            Summary: change in behavior of OUTPUT chain reject rule in
>                     2.6.19?
>     Kernel Version: 2.6.19
>             Status: NEW
>           Severity: normal
>              Owner: networking_netfilter-iptables@kernel-bugs.osdl.org
>          Submitter: maccetta@laurelnetworks.com
> 
> 
> Between 2.6.18 and 2.6.19 (and 2.6.19.1) we've observed that a reject
> rule on the OUTPUT chain no longer causes a connection attempt to abort
> immediately with "Connection refused".  As a specific example, this rule
> 
> iptables -A  OUTPUT -p tcp --destination-port 23 \
>   --destination 10.0.20.1  -j REJECT --reject-with tcp-reset
> 
> will cause a telnet connection to 10.0.20.1 to fail immediately under
> 2.6.18 but will take minutes to timeout under 2.6.19.  A "git bisect"
> identifies change 9d02002d2dc2c7423e5891b97727fde4d667adf1 as the
> culprit.  The change description gives no hint that this effect was
> intended.  Is this a regression?
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
