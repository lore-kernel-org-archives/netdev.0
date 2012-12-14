From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Fri, 14 Dec 2012 16:59:57 -0500
Message-ID: <50CBA15D.6010805@mojatatu.com>
References: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com> <50C91506.70903@redhat.com> <20121213094719.3a7a9408@nehalam.linuxnetplumber.net> <20121213.140023.2131448980265576282.davem@davemloft.net> <20121213110404.6d662baa@nehalam.linuxnetplumber.net> <50CA37DA.1090905@mojatatu.com> <20121213140218.2c705bb5@nehalam.linuxnetplumber.net> <50CA588F.9040800@mojatatu.com> <20121213143712.6932cb22@nehalam.linuxnetplumber.net> <50CA5D39.5060003@mojatatu.com> <50CB58EB.9050302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, or.gerlitz@gmail.com,
	netdev@vger.kernel.org, mst@redhat.com, john.r.fastabend@intel.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:56896 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464Ab2LNWAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 17:00:05 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so6690251ieb.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 14:00:05 -0800 (PST)
In-Reply-To: <50CB58EB.9050302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-14 11:50 AM, Vlad Yasevich wrote:
>
> Interesting.  But, but how complex would be be to configure a vlan
> filter for say 10 different vlans,

Shouldnt be hard. At the simple level you need one rule per VLAN.
I am assuming only one vm per vlan and that you can key on something
in the header.

> each one of them only permitted
> to be forwarded to their respective VM.

Again assuming something in the header is going to say "this packet
is allowed to go to this VM", a MAC address, an IP src/destination
etc, correct?

  Oh, and Vlan tags should
> be stripped when they are being forwarded.

Assuming they are not already stripped at vnetx,
you could write a very simple action (probably one page of code) to 
strip vlans and do everything at br0;
Your filter finds them at br0, your action strips them and pipes to 
another action that redirects to the correct device. i.e in unix speak:
filter at br0 for VMx | strip vlan tag | redirect to vnetx

At the very minimal you need to identify those packets and that depends 
where you want to deploy the policy.
If you deploy at the br device, you will see the raw packet i.e the vlan
header wont be stripped.
i.e youd have to enter some u32 rule with protocol "protocol 802.1q"
If you deploy at each vnetx device assuming it is a vlan device, you 
wont see the vlan headers and you'll have to key on something else on 
the header "protocol ip"

cheers,
jamal
