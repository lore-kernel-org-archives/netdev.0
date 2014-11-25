From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 08:19:36 -0800
Message-ID: <5474AC18.8040809@cumulusnetworks.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-3-git-send-email-jiri@resnulli.us> <5474A25C.3080505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48319 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbaKYQTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:19:45 -0500
In-Reply-To: <5474A25C.3080505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14, 7:38 AM, Jamal Hadi Salim wrote:
> On 11/25/14 05:28, Jiri Pirko wrote:
>> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
>> u16 vid to drivers from there.
>>
>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> I know this maintains status quo of what is already in the kernel.
> But we need to take care of policy (pass it from user space) which
> dictates how to proceed on failure. Three possible options:
> 1) If something fails just continue with the rest of the transaction.
> Return success if at least one thing succeeds.
> 2) If something fails stop transaction and return some partial success 
> code
> 3) If something fails undo everything that has been done and return 
> failure.
>
> So two bits from somewhere would be useful to send from userspace->kernel
>
>

ack to what jamal said.  In the model where sw and hw must be in sync, 
we need a mechanism to roll back in this approach.

I like that you are using existing ops.
To avoid the synchronization problem or to make the rollback easier, You 
can still use existing ops and move this into the bridge driver.
ie call ndo_fdb_add/del and ndo_bridge_setlink/ndo_bridge_getlink on the 
bridge port from within the bridge driver.

Again, vote for change ndo_bridge_setlink/ndo_bridge_getlink to be 
renamed to ndo_setlink/getlink for other netdevs. I can submit a patch.
