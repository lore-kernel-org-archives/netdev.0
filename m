From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge -try4
Date: Fri, 27 Mar 2009 10:47:32 +0100
Message-ID: <20090327094731.GB4582@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090326155205.GA28868@psychotron.englab.brq.redhat.com> <20090327.003819.234492275.davem@davemloft.net> <49CC85E9.7070903@trash.net> <20090327084138.GA4582@psychotron.englab.brq.redhat.com> <49CC948B.8020005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758542AbZC0Juj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49CC948B.8020005@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Mar 27, 2009 at 09:55:39AM CET, kaber@trash.net wrote:
> Jiri Pirko wrote:
>> Fri, Mar 27, 2009 at 08:53:13AM CET, kaber@trash.net wrote:
>>> >
>>> > Me neither, but I don't think this approach can be done without the
>>> > hook. While I still find it questionable whether this mode really
>>> > needs to be supported for a bridge at all
>>
>> Well there is I think nothing unusual in this net scheme. And by for example
>> the increasing setups with kvm/bridging it will be needed more and more.
>
> Mangling ARP packets for load-balancing purposes seems quite unusual.

Well, there are many unusual things, that do not imply that they should not be
supported...

>>> , an alternative approach
>>> would be to have bonding add FDB entries for all secondary MACs to
>>> make bridging treat them as local.
>>
>> Yes - that is the clear way. But there's not really straihtforward way to do
>> this. The clear approach would be to extend struct net_device for list of these
>> mac addresses and let the drivers (binding) fill it and bridge to process it.
>> But I don't know.
>
> We have a list of secondary unicast addresses, but that might not
> be suitable in this case since the addresses are (mostly) intended
> not to be visible to the stack if I understood correctly.

I agree this list is not suitable for this - it's used for different purpose and
I think it would be not wise to mix it with what we want...
