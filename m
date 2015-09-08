From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net v3] ipv6: fix multipath route replace error recovery
Date: Mon, 07 Sep 2015 17:42:18 -0700
Message-ID: <55EE2EEA.5040109@cumulusnetworks.com>
References: <1441572402-39024-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Michal Kubecek <mkubecek@suse.cz>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34601 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbbIHAmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 20:42:19 -0400
Received: by padhy16 with SMTP id hy16so105578275pad.1
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 17:42:19 -0700 (PDT)
In-Reply-To: <1441572402-39024-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/6/15, 1:46 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Problem:
> The ecmp route replace support for ipv6 in the kernel, deletes the
> existing ecmp route too early, ie when it installs the first nexthop.
> If there is an error in installing the subsequent nexthops, its too late
> to recover the already deleted existing route
>
> This patch fixes the problem with the following:
> a) Changes the existing multipath route add code to a two stage process:
>    build rt6_infos + insert them
> 	ip6_route_add rt6_info creation code is moved into
> 	ip6_route_info_create.
> b) This ensures that all errors are caught during building rt6_infos
>    and we fail early
>
The other way I have been thinking of solving the problem is to mark the 
sibling routes being replaced with some state
...so they can be restored on error. Still figuring out a way to do this 
in a clean and non-intrusive way.
Or maybe  just save the sibling routes (rt6_infos) being replaced in a 
list and re-insert them on error.
