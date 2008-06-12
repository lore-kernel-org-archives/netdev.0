From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Thu, 12 Jun 2008 18:03:38 +0200
Message-ID: <485148DA.2060508@trash.net>
References: <20080610205633.11186.45499.stgit@dale>	 <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net> <71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	amar.mudrankit@qlogic.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: Ramachandra K <ariston@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43817 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbYFLQDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 12:03:42 -0400
In-Reply-To: <71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramachandra K wrote:
> On Wed, Jun 11, 2008 at 12:17 PM, Patrick McHardy <kaber@trash.net> wrote:
>> Since I didn't receive anything but a "its too complex" in
>> response to my previous question, let me ask again: why are
>> you inventing a new sysfs interface (combined with ~15 module
>> parameters) instead of using the existing standard interfaces
>> for this?
> 
> Can you please elaborate on the standard interfaces you are referring to ?
> 
> Also as Roland mentioned in the other thread, echo-ing the parameters
> to sysfs files
> is a pretty straightforward way to configure the interfaces. Users
> can setup configuration files to configure QLogic VNIC interfaces
> specifying the name of the interface, various parameters of the
> QLogic EVIC gateway target they want to use  and a simple user level
> script parses the configuration file and echoes the parameters to the driver.


We introduced the rtnl_link API to avoid having each driver
come up with its own method of creating virtual network devices.

Besides the fact that it is the interface intended to be used
for this kind of thing and the advantages mentioned in my
response to Roland, looking at your interface, there are a
few more advantages from integrating this cleanly in iproute:

 > +echo -n 00066a01de000037 		 > 
/sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/ioc_guid
 > +echo -n fe8000000000000100066a11de000037 > 
/sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/dgid
 > +echo -n ffff 				 > 
/sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/pkey

I guess life would be easier for users if those parameters can
be generated in userspace or at least looked up in something
like the maps in /etc/iproute2/.

 > +echo -n 100 				 > 
/sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/heartbeat

I assume thats some kind of timing parameter. iproute
would allow to specify the (undocumented) unit and convert
it appropriately.

In any case, things like tx_csum and rx_csum definitely do
not belong in this interface.

>>> +# An interface can be deleted by echoing the name of the interface to be
>>> deleted
>>> +# to delete_vnic file
>>> +echo -n veth1 > /sys/class/infiniband_qlgc_vnic/interfaces/delete_vnic
>>
>> This clearly shows the advantage of being able to use echo
>> for configuration.
> 
>>From this statement, I thought you agreed with the advantage of echo for
> configuration.

Sorry, that wasn't meant seriously :)
