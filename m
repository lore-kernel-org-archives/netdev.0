From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Sat, 15 Dec 2012 15:52:02 -0500
Message-ID: <50CCE2F2.6040503@redhat.com>
References: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com> <50C91506.70903@redhat.com> <20121213094719.3a7a9408@nehalam.linuxnetplumber.net> <20121213.140023.2131448980265576282.davem@davemloft.net> <20121213110404.6d662baa@nehalam.linuxnetplumber.net> <50CA37DA.1090905@mojatatu.com> <20121213140218.2c705bb5@nehalam.linuxnetplumber.net> <50CA588F.9040800@mojatatu.com> <20121213143712.6932cb22@nehalam.linuxnetplumber.net> <50CA5D39.5060003@mojatatu.com> <50CB58EB.9050302@redhat.com> <50CBA15D.6010805@mojatatu.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, or.gerlitz@gmail.com,
	netdev@vger.kernel.org, mst@redhat.com, john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763Ab2LOUwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2012 15:52:08 -0500
In-Reply-To: <50CBA15D.6010805@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/14/2012 04:59 PM, Jamal Hadi Salim wrote:
> On 12-12-14 11:50 AM, Vlad Yasevich wrote:
>>
>> Interesting.  But, but how complex would be be to configure a vlan
>> filter for say 10 different vlans,
>
> Shouldnt be hard. At the simple level you need one rule per VLAN.
> I am assuming only one vm per vlan and that you can key on something
> in the header.
>
>> each one of them only permitted
>> to be forwarded to their respective VM.
>
> Again assuming something in the header is going to say "this packet
> is allowed to go to this VM", a MAC address, an IP src/destination
> etc, correct?

The VLAN id in this case is what should decide where the packet is going.

>
>   Oh, and Vlan tags should
>> be stripped when they are being forwarded.
>
> Assuming they are not already stripped at vnetx,
> you could write a very simple action (probably one page of code) to
> strip vlans and do everything at br0;
> Your filter finds them at br0, your action strips them and pipes to
> another action that redirects to the correct device. i.e in unix speak:
> filter at br0 for VMx | strip vlan tag | redirect to vnetx

So you would completely bypass the bridge?  Not sure how much I like 
that since what would happen if 2 VMs are to share VLAN.  In such a 
case, broadcasts/multicasts only should only get forwarded to both of
these VMs.

I guess we could add the filters on the vnetx interfaces (which are just
taps).  Then its 2 filters per vlan (1 ingress 1 egress).  Need to think 
about this a bit.

Thanks
-vlad
>
> At the very minimal you need to identify those packets and that depends
> where you want to deploy the policy.
> If you deploy at the br device, you will see the raw packet i.e the vlan
> header wont be stripped.
> i.e youd have to enter some u32 rule with protocol "protocol 802.1q"
> If you deploy at each vnetx device assuming it is a vlan device, you
> wont see the vlan headers and you'll have to key on something else on
> the header "protocol ip"
>
> cheers,
> jamal
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
