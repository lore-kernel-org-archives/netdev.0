From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] sctp: properly latch and use autoclose value from sock to association
Date: Fri, 6 Dec 2013 15:46:31 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B746B@saturn3.aculab.com>
References: <52A0A300.3010409@gmail.com> <1386343755-14130-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Wang Weidong" <wangweidong1@huawei.com>,
	"David Miller" <davem@davemloft.net>,
	"Vlad Yasevich" <vyasevich@gmail.com>, <netdev@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>, <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44493 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753530Ab3LFPrQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 10:47:16 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01796-01 for <netdev@vger.kernel.org>;
 Fri,  6 Dec 2013 15:47:15 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386343755-14130-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Neil Horman
> Currently, sctp associations latch a sockets autoclose value to an association
> at association init time, subject to capping constraints from the max_autoclose
> sysctl value.  This leads to an odd situation where an application may set a
> socket level autoclose timeout, but sliently sctp will limit the autoclose
> timeout to something less than that.
> 
> Fix this by modifying the autoclose setsockopt function to check the limit, cap
> it and warn the user via syslog that the timeout is capped.  This will allow
> getsockopt to return valid autoclose timeout values that reflect what subsequent
> associations actually use.
...
> +	if (sp->autoclose > net->sctp.max_autoclose) {
> +		pr_warn("Capping autoclose value %d to defined maximum of %lu\n",
> +			sp->autoclose, net->sctp.max_autoclose);
> +		sp->autoclose = net->sctp.max_autoclose;
> +	}

Is it really reasonable to allow a user to spam syslog this way?

	David
