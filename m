From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next V6 02/14] bridge: Add vlan filtering infrastructure
Date: Tue, 22 Jan 2013 12:32:45 -0500
Message-ID: <50FECD3D.2040605@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com> <1358360289-23249-3-git-send-email-vyasevic@redhat.com> <CAHXqBFKg6Vp5=dprDYKON2LmshhX+nSPF7KRHiQmOS68PrQq-A@mail.gmail.com> <50FC307A.5090003@redhat.com> <20130120113825.759b4a58@nehalam.linuxnetplumber.net> <50FC9F03.5000102@redhat.com> <20130121134534.78032a54.shmulik.ladkani@gmail.com> <50FEA2CF.4060406@redhat.com> <20130122175524.033c6f7f.shmulik.ladkani@gmail.com> <CB4696DA7737D0409230B481D0363B1414F0E6029D@HQ1-EXCH03.corp.brocade.com> <20130122091746.7a3820e9@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145Ab3AVRcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 12:32:47 -0500
In-Reply-To: <20130122091746.7a3820e9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2013 12:17 PM, Stephen Hemminger wrote:
> I appreciate all the work on this. And at this point it may seem like it
> will never get in mainline. As far as I am concerned these are the key
> features:
>
>    1. VLAN filtering on both ingress and egress using same table

Can you elaborate a bit more what you mean by this?

>    2. O(1) based bit map table
>    3. netlink based configuration and dump (per port). Okay to just provide the
>      bitmap
>    4. kernel feature should be optional
>    5. default behavior has to be to allow all VLAN's for backwards compatibility.

I think with the exception of 2, all of the above requirements are met 
by the current code.  As for #2, a hash approach provides most of the 
performance gain and allows for extensibility.
I am currently removing the list from all the hot paths, and we could 
make the hash wider if you want to make each hlist shorter.

>
> Extra credit for:
>    * cleaning up kernel VLAN API's. Eliminate vlan_buggy() and any/all cases
>      where error is not detected until first packet

I don't think we can truly do that since non-vlans frames should work on 
vlan_buggy interfaces.

I could also remove all the HW filtering calls out of the code since 
they are not truly needed now due to running in promisc mode.

-vlad

>
> I don't care about:
>    * sysfs API's - sysfs is not good for binary (like bitmap), and doing
>      a list
>    * split ingress/egress
>    * future extensibility ideas - do it right now, then do the next step;
>      don't get ahead of yourself.
>
