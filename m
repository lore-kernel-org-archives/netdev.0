From: Moni Shoua <monis@Voltaire.COM>
Subject: Re: [PATCH]: net/bonding: Enable to change device type before enslaving
Date: Thu, 17 Apr 2008 09:29:03 +0300
Message-ID: <4806EE2F.2090704@Voltaire.COM>
References: <47FE2DBF.7080803@voltaire.com> <21771.1207860504@death> <48021410.5040806@voltaire.com> <11141.1208374066@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Olga Stern <olgas@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:36869 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751999AbYDQG3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 02:29:16 -0400
In-Reply-To: <11141.1208374066@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Moni Shoua <monis@voltaire.com> wrote:
>
>   
>>> 	Does this mean that the automatic selection on first enslavement
>>> is no longer needed, and all setting of the type for IB devices must
>>> occur prior to first enslavement?
>>>
>>> 	Or is this more of a special case for some devices, and the
>>> automatic selection is still correct for most cases?
>>>
>>>       
>> I think that the later is closer to the truth. 
>> The goal is to modify the bonding module to work with IPoIB slaves but
>> with as small as possible changes to what already exists.
>>
>> In details, the bonding net device device gets its type by
>> ether_setup(), which runs for all types of slaves and I don't see a way
>> to change that.  However, bonding master for IPoIB slaves requires a
>> different device type setting before it comes up for some OSs (redhat 4
>> for instance). On other OSs I don't see the problem and I guess that
>> this is because master becomes up only after it has slaves.
>>     
>
> 	If I'm reading the above correctly, then this type selection is
> only needed for Red Hat 4 (or, really, versions of bonding prior to when
> the bonding master started to set its carrier state based upon the state
> of the slaves), correct?
>
> 	If that's the case, then is this patch is fixing a problem that
> doesn't exist in the mainline?  If this isn't a problem with the current
> driver (where "current" here seems to be bonding 3.0.3 and later, which
> is about two years old), I don't see why it should go into the mainline.
>
> 	Am I misunderstanding something?
>
> 	-J
>
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
The problem was seen under  RedHat 4 with a bonding driver from 2.6.24 
with backports.
We deliver this module to customers who use IPoIB.
However, the bug is  not only for RedHat necessarily. Anywhere that will do
1. ifup bond0
2. Enslave ib0,ib1 to bond0
will end up the same problem described above.

