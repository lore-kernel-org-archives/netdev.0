From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: net/ipv4/fib_trie.c:1550 suspicious rcu_dereference_check() usage
Date: Tue, 10 Mar 2015 09:52:26 -0700
Message-ID: <54FF214A.1040703@redhat.com>
References: <CAOMZO5Aghpf7b-p0YWB_PdF-frN-rERmdjoUOk+PW_rzJY+eMQ@mail.gmail.com> <CAOMZO5C4Tg12r7W7msm_KPEhV1QxR1Uij-f_UBtVRUeTFxzn_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>
To: Fabio Estevam <festevam@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbbCJQwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 12:52:31 -0400
In-Reply-To: <CAOMZO5C4Tg12r7W7msm_KPEhV1QxR1Uij-f_UBtVRUeTFxzn_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/10/2015 09:20 AM, Fabio Estevam wrote:
> On Tue, Mar 10, 2015 at 1:19 AM, Fabio Estevam <festevam@gmail.com> wrote:
>> Hi,
>>
>> On a imx6sl-warp board running linux-next 20150306:
>>
>> root@imx6sl-warp:~# reboot
>>
>> The system is going down for reboot NOW!(ttymxc0) (Wed Feb 25 18:41:59 2015):
>> INIT: Switching to runlevel: 6
>> INIT: Sending processes the TERM signal
>> INIT: Sending processe Stopping syslogd/klogd: stopped syslogd (pid 301)
>> stopped klogd (pid 304)
>> done
>> Deconfiguring network interfaces... [   36.083246]
>> [   36.084753] ===============================
>> [   36.089026] [ INFO: suspicious RCU usage. ]
>> [   36.093217] 4.0.0-rc2-next-20150306-00003-g62c7037-dirty #2699 Not tainted
> It seems that the issue is gone in linux-next 20150310.

I found the bug.  It was in "fib_trie: Only resize tnodes once instead 
of on each leaf removal in fib_table_flush", commit 7289e6dd.  I had 
incorrectly used a rcu_dereference where I should have used an 
rtnl_dereference.  The offending code was removed and replaced 4 days 
ago when "fib_trie: Add key vector to root, return parent key_vector in 
resize", commit 88bae714, was applied.

- Alex
