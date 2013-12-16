From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] SCTP: Reduce log spamming for sctp setsockopt
Date: Mon, 16 Dec 2013 15:24:48 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B749A@saturn3.aculab.com>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Vlad Yasevich" <vyasevich@gmail.com>,
	"David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>, <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:54835 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753978Ab3LPP0I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:26:08 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03931-03 for <netdev@vger.kernel.org>;
 Mon, 16 Dec 2013 15:26:07 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Neil Horman
> During a recent discussion regarding some sctp socket options, it was noted that
> we have several points at which we issue log warnings that can be flooded at an
> unbounded rate by any user.  Fix this by converting all the pr_warns in the
> sctp_setsockopt path to be pr_warn_ratelimited.
> 
> Note there are several debug level messages as well.  I'm leaving those alone,
> as, if you turn on pr_debug, you likely want lots of verbosity.
...
> -		pr_warn("Use of struct sctp_assoc_value in delayed_ack socket option deprecated\n");
> -		pr_warn("Use struct sctp_sack_info instead\n");
> +		pr_warn_ratelimited("Use of struct sctp_assoc_value in delayed_ack socket option
> deprecated\n");
> +		pr_warn_ratelimited("Use struct sctp_sack_info instead\n");

Do you need to send these as a single ratelimited message?

	David
