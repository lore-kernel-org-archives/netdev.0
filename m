From: <Narendra_K@Dell.com>
Subject: RE: PATCH: Network Device Naming mechanism and policy
Date: Mon, 19 Oct 2009 17:00:50 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091013150839.GD32107@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013173638.GE1119@ldl.fc.hp.com> <20091016003245.GD29672@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com> <20091016152053.GA9862@ldl.fc.hp.com> <1255707193.2869.12.camel@achroite> <20091016214024.GA10091@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<Matt_Domsch@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Charles_Rose@Dell.com>
To: <dannf@hp.com>, <bhutchings@solarflare.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091016214024.GA10091@ldl.fc.hp.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> > > And how would the regular file look like in terms of holding 
>> > > ifindex of the interface, which can be passed to libnetdevname.
>> > 
>> > I can't think of anything we need to store in the regular file. If 
>> > we have the kernel name for the device, we can look up the ifindex 
>> > in /sys. Correct me if I'm wrong, but storing it ourselves seems 
>> > redundant.
>> 
>> But the name of a netdev can change whereas its ifindex never does.
>> Identifying netdevs by name would require additional work to update 
>> the links when a netdev is renamed and would still be prone to race 
>> conditions.  This is why Narendra and Matt were proposing to 
>store the 
>> ifindex in the node all along...
>
>Matt, Ben and I talked about a few other possibilities on IRC.
>The one I like the most at the moment is an idea Ben had to 
>creat dummy files named after the ifindex. Then, use symlinks 
>for the kernel name and the various by-$property 
>subdirectories. This means the KOBJ events will need to expose 
>the ifindex.
>

I suppose the KOBJ events already expose the ifindex of a network
interface. The file "/sys/class/net/ethN/uevent" contains INTERFACE=ethN
and IFINDEX=n already. But it looks like udev doesn't use it in any way.
For example, with the kernel patch the "/sys/class/net/ethN/uevent"
contains in addition to the above details, MAJOR=M and MINOR=m which the
udev knows how to make use of with a rule like 

SUBSYSTEM=="net", KERNEL!="tun", NAME="netdev/%k", MODE="0600".

>I'm a novice at net programming, but I'm told that ifindex is 
>the information apps ultimately require here.

Yes. The minor number of the device node is retreived by libnetdevname
by "stat"ing the pathname which happens to be ifindex of the device and
it is mapped to corresponding kernel name by "if_indextoname"  call.

With regards,
Narendra K  
