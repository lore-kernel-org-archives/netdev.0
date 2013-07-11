From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Fix vs->vni_list locking.
Date: Wed, 10 Jul 2013 19:55:23 -0700 (PDT)
Message-ID: <20130710.195523.248795155616961560.davem@davemloft.net>
References: <20130710155840.73e8da09@nehalam.linuxnetplumber.net>
	<CALnjE+rO7Npw=rU_VL7T1pPDdFBKXB3KpVbpf_jQ0cJ6+ah1nQ@mail.gmail.com>
	<20130710162509.75bbb922@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab3GKCzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 22:55:24 -0400
In-Reply-To: <20130710162509.75bbb922@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 10 Jul 2013 16:25:09 -0700

> On Wed, 10 Jul 2013 16:08:38 -0700
> Pravin Shelar <pshelar@nicira.com> wrote:
> 
>> On Wed, Jul 10, 2013 at 3:58 PM, Stephen Hemminger
>> <stephen@networkplumber.org> wrote:
>> > On Wed, 10 Jul 2013 15:04:44 -0700
>> > Pravin B Shelar <pshelar@nicira.com> wrote:
>> >
>> >> Use rtnl lock to protect vs->vni_list updates.
>> >>
>> >> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> >> ---
>> >
>> > I don't think this is necessary. I intentionally changed the
>> > locking when socket management was moved to a work queue.
>> > The vxlan_net socket lock is held there already, and finer grain.
>> 
>> what abt vxlan_dellink()?
>> it is deleting vxlan-dev from hash table without lock.
> 
> Ok, then this should fix it.

Looks good, one minor thing:

>  {
>         struct vxlan_dev *vxlan = netdev_priv(dev);
> +       struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);

Please declare 'vn' on the first line rather than the second.

A formal submission with that fixup and a signoff, and I'll apply
this.

Thanks.
