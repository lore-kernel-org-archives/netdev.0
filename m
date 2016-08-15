From: Amir Vadai <amir@vadai.me>
Subject: Re: [RFC net-next 0/2] net/sched: cls_flower, act_mirred: VXLAN
 redirect using TC
Date: Mon, 15 Aug 2016 14:36:53 +0300
Message-ID: <20160815113653.GD19058@office.localdomain>
References: <20160814140652.15985-1-amir@vadai.me>
 <CAM_iQpXetPgj_nCdYL73r_2hDRmnCpa0-WrxN-UbwBsdFgouiQ@mail.gmail.com>
 <20160815071121.GA2024@nanopsycho>
 <20160815081740.GA19058@office.localdomain>
 <20160815090804.GB19058@office.localdomain>
 <faa0a9ab-fc02-543e-c60a-0d22b253a830@mojatatu.com>
 <20160815132436.0d1e34b6@pixies>
 <a27a76e8-d7c3-457d-be98-00cf2d942cf8@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Oded Shanoon <odeds@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36385 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762AbcHOLg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 07:36:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so10603028wmf.3
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2016 04:36:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <a27a76e8-d7c3-457d-be98-00cf2d942cf8@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 06:41:14AM -0400, Jamal Hadi Salim wrote:
> On 16-08-15 06:24 AM, Shmulik Ladkani wrote:
> > On Mon, 15 Aug 2016 06:08:10 -0400, jhs@mojatatu.com wrote:
> 
> > > Assuming $VXLAN is actually not a linux netdev of type vxlan?
> > > then the action does vxlan encap redirect sends it to the $VXLAN
> > > dev with encapsulation in place.
> > 
> > I assume Amir refers to vxlan netdev in VXLAN_F_COLLECT_METADATA mode,
> > using the tun_info metadata found in skb_metadata_dst.
> > The action is supposed to assign the tun metadata.
> > 
> 
> I see - so you let the vxlan netdev do the encap?
> Would it still scale to a _very large_ number of tunnels?
> How many netdevs are you going to use? I am assuming you will hit
> a nasty lock somewhere(qdisc?) if you use only one.
Having a netdev per tunnel is problematic in its memory use [1].
User can take each of the approaches. Can have a shared netdev, but will
have some contention on the qdisc lock, or create a vxlan dev per VNI
and increase memory use.
When offloading will be added, shared netdev will enjoy all worlds - low
memory use and no lock contention.


[1] - http://www.netdevconf.org/1.1/proceedings/slides/ahern-aleksandrov-prabhu-scaling-network-cumulus.pdf

> 
> cheers,
> jamal
