From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [ipv6] valid_lft and active connections
Date: Tue, 14 Jun 2011 20:41:50 +0900
Message-ID: <1308051710.3424.15.camel@takos>
References: <4DF73A6D.1050809@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:38954 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756083Ab1FNLu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 07:50:57 -0400
In-Reply-To: <4DF73A6D.1050809@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Stefan (metze) Metzmacher wrote:
> If I use ipv6 addresses with valid_lft != forever, the ipv6 addresses
> are removed from the interface if the valid_lft expires, even if there're
> established connection which use with address.
> 
> Would it be possible keep the address until the last active connection
> is closed? Otherwise the usable of the privacy extensions will make
> very long living tcp connections impossible.
> 

I cannot imagine why you do not hear RAs before the address expires.

And well, I don't think it is a good idea because it is not what
"valid lifetime" means.

We have 3 states:

1) time <= preferred lifetime
2) preferred lifetime < time <= valid lifetime
3) valid lifetime < lifetime

You can make new connection during the period of 1 and you can continue
using that connection during the period of 1 and 2.

Ask network administrator to advertise longer "valid" lifetime, if
needed, and you may want to make net.ipv6.conf.*.max_addresses larger.


> It would be also ok to add a new special value "used" similar to "forever",
> which triggers the modified behavior.

???

--yoshfuji

