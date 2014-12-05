From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2 REGRESSIONS v2] ss: Fix layout/output issues
 introduced by regression
Date: Fri, 5 Dec 2014 19:06:42 +0200
Message-ID: <20141205170641.GA23226@angus-think.wlc.globallogic.com>
References: <1417791796-7739-1-git-send-email-vadim4j@gmail.com>
 <5481E77C.7070102@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:41088 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbaLERQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:16:27 -0500
Received: by mail-la0-f54.google.com with SMTP id pv20so1023183lab.27
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 09:16:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5481E77C.7070102@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 [...]
> >@@ -2912,11 +2910,12 @@ static void netlink_show_one(struct filter *f,
> >  		printf("%-*s ", state_width, "UNCONN");
> >  	printf("%-6d %-6d ", rq, wq);
> >
> >-	if (resolve_services)
> >-	{
> >+	if (resolve_services) {
> >  		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
> >  					sizeof(prot_name)));
> >-	}
> >+	} else
> >+		printf("%*d:", addr_width, prot);
> >+
> 
>    Extra empty line hardly needed here. And if iproute2 follows the Linux
> kernel style, {} should be used in all arms of the *if* statement (since
> it's used in one case).
> 
> >
> >  	if (pid == -1) {
> >  		printf("%-*s ", serv_width, "*");
> 
> WBR, Sergei
> 

You mean change to this ?

	if (resolve_services) {
 		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
 					sizeof(prot_name)));
	} else {
		printf("%*d:", addr_width, prot);
        }

Thanks,
