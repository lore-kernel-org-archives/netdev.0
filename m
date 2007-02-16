From: Ben Greear <greearb@candelatech.com>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Fri, 16 Feb 2007 11:04:02 -0800
Message-ID: <45D60022.9060701@candelatech.com>
References: <20070216072928.GA1599@ff.dom.local>	<45D55FF0.8090309@candelatech.com> <20070216103115.517f1a4c@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:53934 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946056AbXBPTGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 14:06:55 -0500
In-Reply-To: <20070216103115.517f1a4c@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 15 Feb 2007 23:40:32 -0800
> Ben Greear <greearb@candelatech.com> wrote:

>> Maybe there should be something like an ASSERT_NOT_RTNL() in the 
>> flush_scheduled_work()
>> method?  If it's performance criticial, #ifdef it out if we're not 
>> debugging locks?
>>
> 
> You can't safely add a check like that. What if another cpu had acquired
> RTNL and was unrelated.

I guess there isn't a way to see if *this* thread is the owner of the RTNL
currently?  I think lockdep knows the owner...maybe could query it somehow,
or just save the owner in the mutex object when debugging is enabled...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

