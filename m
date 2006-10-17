From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Tue, 17 Oct 2006 10:18:54 -0700
Message-ID: <4535107E.9010609@intel.com>
References: <44AC05A8.9030503@intel.com>	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>	 <1152191018.5103.48.camel@jzny2>	 <20060706.235909.78729229.davem@davemloft.net>	 <1152275283.5341.144.camel@jzny2>  <4533D594.2070908@intel.com> <1161090331.5555.10.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12320 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1751343AbWJQRXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 13:23:33 -0400
To: hadi@cyberus.ca
In-Reply-To: <1161090331.5555.10.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2006-16-10 at 11:55 -0700, Auke Kok wrote:
>> jamal wrote:
> 
>>> I think when the e1000 says via ethtool "rx is on" - it means that it 
>>> is _advertising_ flow control as opposed to detecting partner has flow
>>> control capability.
>>> Auke, can you also check this as well?
>> Just found this in my todo box - a bit late :(
>>
>> yes, that appears to be the correct interpretation: we never read back the 
>> detected FC  state from the hardware.
> 
> It sounds to me that ethttool needs to have this semantic fix.
> IOW, ethttool doesnt differentiate the two items:
> a) advertised parameters.
> b) link partner negotiated parameters.
> 
> and instead #a becomes #b after negotiation.

that's odd and confusing, we should keep them separate.

> methinks this needs fixing. Dave? Jeff?

Alternatively, we can report in the driver at link up time what FC settings were 
succesfull using printk. The output of `eththool eth0` would be the best place to put 
this output as well since that displays "status" and not "settings" which are displayed 
with '-a|-A' options of ethtool. Lets keep `-a|-A` the same and work on showing 
negotiated FC parameters in `ethtool ethX` instead.

Auke

