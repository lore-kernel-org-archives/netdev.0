From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 net] net: Always untag vlan-tagged traffic on input.
Date: Mon, 29 Sep 2014 15:05:43 +0200
Message-ID: <20140929130543.GB1839@nanopsycho.orion>
References: <1407523333-31455-1-git-send-email-vyasevic@redhat.com>
 <54295449.7030203@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vladislav Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:41199 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbaI2NFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 09:05:47 -0400
Received: by mail-wg0-f46.google.com with SMTP id k14so2909930wgh.29
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 06:05:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <54295449.7030203@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 29, 2014 at 02:44:57PM CEST, nicolas.dichtel@6wind.com wrote:
>Le 08/08/2014 20:42, Vladislav Yasevich a =E9crit :
>[snip]
>>
>>The patch attempt to fix this another way.  It moves the vlan header
>>stipping code out of the vlan module and always builds it into the
>>kernel network core.  This way, even if vlan is not supported on
>>a virtualizatoin host, the virtual machines running on top of such
>>host will still work with VLANs enabled.
>After this patch (0d5501c1c828 ("net: Always untag vlan-tagged traffic=
 on
>input.")), tcpdump will not be able to display the VLAN header on inpu=
t path.
>Is this really intended?

I assume you are talking about the case when CONFIG_VLAN_8021Q is "n"
right? Because if it is "m" of "y" I see no change in the code.

In case of CONFIG_VLAN_8021Q is "n" the only change is that for
non-accelerated path, skb->vlan_tci is set and vlan header is stripped.
This makes the path same to accelerated path.

tcpdump should be able to cope with skb->vlan_tci

>
>
>Regards,
>Nicolas
