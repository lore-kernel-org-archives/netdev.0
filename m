From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Fri, 13 Jun 2008 17:20:07 +0200
Message-ID: <48529027.1090309@trash.net>
References: <20080610205633.11186.45499.stgit@dale>	 <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net>	 <71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>	 <485148DA.2060508@trash.net> <c8028d330806121409x27a4d596k571ce87934e89371@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ramachandra K <ariston@gmail.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org
To: Amar Mudrankit <amar.mudrankit@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44062 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438AbYFMPUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 11:20:12 -0400
In-Reply-To: <c8028d330806121409x27a4d596k571ce87934e89371@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amar Mudrankit wrote:
> I have just started on getting into the rtnl_link API.  There are few
> queries on it, plz correct me if I am wrong.
> 
> 1.  If I understand it correctly, this interface is not text based.
> Hence, it looks like this interface needs a separate user program
> which actually sends the parameters to the driver. A separate user
> program for each driver, as their configuration parameters might be
> different. Is it right?

Not necessarily an entire program, you can integrate it in
iproute2 or libnl. Look at ip/iplink_vlan.c in iproute for
an example.

> 2.  I am not sure if there exists a standardized (netlink?) interface
> through which parameters can be passed to kernel.

For virtual network drivers, its rtnl_link, or more generally,
rtnetlink.

> If so, there would
> be standard set of parameters that can be configured and standard set
> of statistics values that can be retrieved from driver. Is it so?

Yes.

> Actually, I tried googling around rtnl_link, but couldn't collect
> sufficient information.
> 
> 3.  Is there any kind of documentation available on this? I tried
> searching on it in Documentation/ directory as well as git log but
> could not locate enough of it.

My fault, I have some unfinished documentation that I never
completed. There are a few examples in the tree:

drivers/net/dummy.c
drivers/net/macvlan.c
drivers/net/ifb.c
drivers/net/veth.c
net/8021q/vlan_netlink.c

macvlan and vlan are probably best suited as an example, dummy
and ifb are too simple and veth is kind of special because it
registers two devices.

If you have questions, feel free to ask.

> 4.  Can anybody point to an ethernet driver as an example of
> implementation of rtnl_link API along with an equivalent user space
> program to configure it?
> 
> That would be of immense help.

See above.

>>> +echo -n 00066a01de000037              >
>>> /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/ioc_guid
>>> +echo -n fe8000000000000100066a11de000037 >
>>> /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/dgid
>>> +echo -n ffff                                  >
>>> /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/pkey
>> I guess life would be easier for users if those parameters can
>> be generated in userspace or at least looked up in something
>> like the maps in /etc/iproute2/.
>>
> 
> Is it the answer of question no 2 above? If so, what about statistics
> of the driver then?

You can dump driver private statistics in the ->fill_xstats function.

>> In any case, things like tx_csum and rx_csum definitely do
>> not belong in this interface.
>>
> 
> We are planning to give ethtool support for the driver in future, in
> which case these 2 parameters will be configured through ethtool.

Yes, thats where it belongs.
