From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 1/5] bonding: mc addresses don't get deleted on enslave
 failure
Date: Thu, 18 Apr 2013 19:15:07 +0200
Message-ID: <51702A1B.5080402@redhat.com>
References: <1366295697-31037-1-git-send-email-nikolay@redhat.com> <1366295697-31037-2-git-send-email-nikolay@redhat.com> <14509.1366304280@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62547 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967395Ab3DRRQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 13:16:40 -0400
In-Reply-To: <14509.1366304280@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/04/13 18:58, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> Add dev_mc_del after err_detach as that's the first error path
>> after they're added. The main issue is the mc addresses' refcount
>> which only gets bumped up.
>>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> 
> 	All 5 of these patches look good to me.  The only minor nits are
> that the above description says "dev_mc_del," but the actual function
> call added is bond_mc_list_flush (which in turn does call dev_mc_dev),
> and that this patch (#1) modifies the lacpdu_multicast variable
> initialization, which isn't really necessary for the bug fix.
> 
> 	-J
> 
> 

Yes, that all is because initially I wrote it directly with dev_mc_del
where I needed the variable and then I changed it to use
bond_mc_list_flush. I'll re-post v2 with updated log message and
without that initialization, sorry about this.

Nik
