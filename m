From: "Amar Mudrankit" <amar.mudrankit@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Fri, 13 Jun 2008 02:39:51 +0530
Message-ID: <c8028d330806121409x27a4d596k571ce87934e89371@mail.gmail.com>
References: <20080610205633.11186.45499.stgit@dale>
	 <20080610210918.11186.64253.stgit@dale> <484F751F.7030407@trash.net>
	 <71d336490806120850x3b5e6172jf4d75850771d6349@mail.gmail.com>
	 <485148DA.2060508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ramachandra K" <ariston@gmail.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:8100 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbYFLVJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 17:09:56 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2207918rvb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 14:09:51 -0700 (PDT)
In-Reply-To: <485148DA.2060508@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2008 at 9:33 PM, Patrick McHardy <kaber@trash.net> wrote:
> Ramachandra K wrote:
>>
>> On Wed, Jun 11, 2008 at 12:17 PM, Patrick McHardy <kaber@trash.net> wrote:
>>>
>>> Since I didn't receive anything but a "its too complex" in
>>> response to my previous question, let me ask again: why are
>>> you inventing a new sysfs interface (combined with ~15 module
>>> parameters) instead of using the existing standard interfaces
>>> for this?
>>
>> Can you please elaborate on the standard interfaces you are referring to ?
>>
>> Also as Roland mentioned in the other thread, echo-ing the parameters
>> to sysfs files
>> is a pretty straightforward way to configure the interfaces. Users
>> can setup configuration files to configure QLogic VNIC interfaces
>> specifying the name of the interface, various parameters of the
>> QLogic EVIC gateway target they want to use  and a simple user level
>> script parses the configuration file and echoes the parameters to the
>> driver.
>
>
> We introduced the rtnl_link API to avoid having each driver
> come up with its own method of creating virtual network devices.
>
> Besides the fact that it is the interface intended to be used
> for this kind of thing and the advantages mentioned in my
> response to Roland, looking at your interface, there are a
> few more advantages from integrating this cleanly in iproute:
>

I have just started on getting into the rtnl_link API.  There are few
queries on it, plz correct me if I am wrong.

1.  If I understand it correctly, this interface is not text based.
Hence, it looks like this interface needs a separate user program
which actually sends the parameters to the driver. A separate user
program for each driver, as their configuration parameters might be
different. Is it right?

2.  I am not sure if there exists a standardized (netlink?) interface
through which parameters can be passed to kernel. If so, there would
be standard set of parameters that can be configured and standard set
of statistics values that can be retrieved from driver. Is it so?

Actually, I tried googling around rtnl_link, but couldn't collect
sufficient information.

3.  Is there any kind of documentation available on this? I tried
searching on it in Documentation/ directory as well as git log but
could not locate enough of it.

4.  Can anybody point to an ethernet driver as an example of
implementation of rtnl_link API along with an equivalent user space
program to configure it?

That would be of immense help.

>> +echo -n 00066a01de000037              >
>> /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/ioc_guid
>> +echo -n fe8000000000000100066a11de000037 >
>> /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/dgid
>> +echo -n ffff                                  >
>> /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/pkey
>
> I guess life would be easier for users if those parameters can
> be generated in userspace or at least looked up in something
> like the maps in /etc/iproute2/.
>

Is it the answer of question no 2 above? If so, what about statistics
of the driver then?

> In any case, things like tx_csum and rx_csum definitely do
> not belong in this interface.
>

We are planning to give ethtool support for the driver in future, in
which case these 2 parameters will be configured through ethtool.

Thanks and Regards,
Amar
