From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/6] bond: Implement a basic set of rtnl link ops
Date: Fri, 30 Oct 2009 11:08:09 +0100
Message-ID: <4AEABB09.10903@trash.net>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>	<1256861906-5059-5-git-send-email-ebiederm@xmission.com>	<4AEAA403.7080204@trash.net> <m1eiols0a4.fsf@fess.ebiederm.org>	<4AEAB2F1.5070200@trash.net> <m1skd1qjzb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40007 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037AbZJ3KIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 06:08:14 -0400
In-Reply-To: <m1skd1qjzb.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>> As for rtnl_link_register it always succeeds so let's just
>>> remove the return code and call it good.
>> You need unroll anyways for the other failure conditions, so
>> why not simply add an err1/2 and be safe for future changes?
> 
> Not a real problem.  I was just thinking of things like the
> dummy driver that have this same issue and the fact that since
> rtnl_link_register never fails we never test the error path.
> So it would be much less error prone and less code to remove
> the possibility of rtnl_link_register failing.

Mhh good point, I think I added the broken dummy code myself :)

The main reason for not returning void from rtnl_link_register()
was so new drivers that are written with rtnl_link in mind from
the beginning (and thus usually don't do anything like default
device creation, sysfs registrations etc.) can simply do
"return rtnl_link_register(&ops)" in their init function. But
that's admittedly not a very strong argument :)

