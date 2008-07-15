From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] af_packet: po->mclist needs locker in reader side
Date: Tue, 15 Jul 2008 18:32:45 +0800
Message-ID: <487C7CCD.8060708@cn.fujitsu.com>
References: <487C127D.9010908@cn.fujitsu.com>	<20080714.205110.266962405.davem@davemloft.net>	<487C573F.3020803@cn.fujitsu.com> <20080715.021144.85711463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57021 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752722AbYGOKh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 06:37:58 -0400
In-Reply-To: <20080715.021144.85711463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-7-15 17:11:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Tue, 15 Jul 2008 15:52:31 +0800
> 
>> As my understanding, packet_dev_mclist() is the only reader who doesn't
>> use same lock as writers(actually it doesn't use any lock).
>> My proposal is that use RTNL to prevent synchronous access to po->mclist.
>> Because packet_dev_mclist() is only called when device be unregistered,
>> the lock will not affect speed too much. 
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> I took a look and it turns out that the RTNL lock is already held when
> that notifier runs, so it seems everything is fine here already.
> 
> So I'll ignore this patch :)

Yes. register_netdevice() holds the lock ;)

