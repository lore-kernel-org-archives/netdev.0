From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] l2tp: fix compile error when CONFIG_IPV6=m and
 CONFIG_L2TP=y
Date: Thu, 20 Sep 2012 15:36:54 +0800
Message-ID: <1348126614.17345.8.camel@cr0>
References: <1347947642-20330-1-git-send-email-amwang@redhat.com>
	 <20120919.164403.1265757047954729748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494Ab2ITHg7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 03:36:59 -0400
In-Reply-To: <20120919.164403.1265757047954729748.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 16:44 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue, 18 Sep 2012 13:54:02 +0800
> 
> > When CONFIG_IPV6=m and CONFIG_L2TP=y, I got the following compile error:
>  ...
> > This is due to l2tp uses symbols from IPV6, so when l2tp is
> > builtin, IPV6 has to be builtin too.
> > 
> > Cc: David Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> The correct way to express this is:
> 
> 	depends on (IPV6 || IPV6=n)
> 
> Which results in the KCONFIG option only being offers in modes
> compatible with the dependency.  Using a 'select' doesn't work
> properly in these kinds of cases.
> 
> Anyways, grep for that string to see how it is used in other similar
> situations.
> 

Thanks for the hints! I will update this patch.
