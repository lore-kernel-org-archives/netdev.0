From: "Hong Hui Xiao" <xiaohhui@cn.ibm.com>
Subject: Re: [Question/Bug] Should the priority of ip rule be unique?
Date: Tue, 12 Jan 2016 20:35:57 +0800
Message-ID: <201601121236.u0CCaAH4030858@d23av02.au.ibm.com>
References: <201601080632.u086WOPd003565@d23av04.au.ibm.com> <5694345D.4040809@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:53898 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934430AbcALMgs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 07:36:48 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <xiaohhui@cn.ibm.com>;
	Tue, 12 Jan 2016 22:36:45 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B9E2C2BB0054
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 23:36:44 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0CCaakI62062706
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 23:36:44 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0CCaC76031025
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 23:36:12 +1100
Received: from d50lp01.ny.us.ibm.com (d50lp01.pok.ibm.com [146.89.104.207])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id u0CCaAH4030858
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 23:36:12 +1100
Received: from /spool/local
	by d50lp01.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <xiaohhui@cn.ibm.com>;
	Tue, 12 Jan 2016 07:36:02 -0500
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <netdev@vger.kernel.org> from <xiaohhui@cn.ibm.com>;
	Tue, 12 Jan 2016 12:35:58 -0000
In-Reply-To: <5694345D.4040809@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Brian. It really helps.




From:   Brian Haley <brian.haley@hpe.com>
To:     Hong Hui Xiao/China/IBM@IBMCN, netdev@vger.kernel.org
Date:   01/12/2016 07:03
Subject:        Re: [Question/Bug] Should the priority of ip rule be 
unique?



On 01/08/2016 01:32 AM, Hong Hui Xiao wrote:
> Hi,
>
>  From the man page of ip rule at [1], it says that "Each rule should 
have
> an explicitly set unique priority value." It is reasonable to have 
unique
> priority for ambiguous rules.
> But I have a set of unambiguous ip rules, do I still need to set the
> priority of to be unique? In practice, I can set ip rules with 
duplicated
> priority, and things works as expected. I want to confirm with iproute
> developers if this is a support usecase. If so, the information in man
> page may need updates.
>
> 5000: from all fwmark 0x4000000/0xffff0000 lookup table0
> 5000: from all fwmark 0x4010000/0xffff0000 lookup table1
> 5000: from all fwmark 0x4020000/0xffff0000 lookup table2
> 5000: from all fwmark 0x4030000/0xffff0000 lookup table3
>
>
> [1] http://man7.org/linux/man-pages/man8/ip-rule.8.html (search for
> "unique")

No, you shouldn't need to set the priority in this case as each rule is 
unique. 
  From reading earlier in the man page, and looking at the code, the rules 
are 
ordered and scanned in order of decreasing priority, with a lower priority 
being 
higher.  In the case of rules with the same priority they are ordered 
based on 
the order in which they were added to the kernel.

So I guess the man page could be tweaked a little, given "should" seems to 

follow the liberal IANA meaning of recommended, but not required.

-Brian
