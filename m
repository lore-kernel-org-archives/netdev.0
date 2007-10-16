From: jamal <hadi@cyberus.ca>
Subject: Re: Resend: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 07:26:42 -0400
Message-ID: <1192534002.4480.52.camel@localhost>
References: <ifgroup.20071015.1192520046.panther@balabit.hu>
	 <a6713ba13c49b7fa20073d8abf1862480c2799e0.1192457385.git.panther@balabit.hu>
	 <1192531516.4480.33.camel@localhost>  <47149B04.30607@balabit.hu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: panther@balabit.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47149B04.30607@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-16-10 at 13:05 +0200, Laszlo Attila Toth wrote:

> That sounds great but for what whould you like to use? It may help me 
> for the implementation.

For example i may want to add a tc rule to a group of interfaces.
tc BNF roughly looks like:
tc <object> <operation> <target>

Where targe is := <dev devname>
It may be useful to extend "target" to include alternatively a group of
devices.
The way i would see that done is to add a little wrapper to tc to first
ask the kernel for a list of interfaces and then invoke each with the
equivalent of current syntax.
Did that make sense?

> Currently it is not available since the the 
> net_device structure holds the group id and for this get operation an 
> iteration (of net_devices) may be necessary...

I understand - but i would rather do the iteration in the kernel than in
user space and save myself a gazillion netlink messages.

> We didn't want to use multiple groups in favour of masked group ids. 
> What kind of usage needs other implementation?

Same lazyperson use cases as above; in one case i may want to set a rule
to group = {eth0, eth1, eth10} and in another {eth0,eth5}. I realize
this may be more involved something clever for an implementation (eg
using a bitmap instead of a straight int) - so if it not a simple thing,
just defer it to some later time.

Ok, now that you are asking, heres another one feature request for
you;-> It would be nice if i can set a group based on a regular
expression of a devices name; eg "ppp*". Use case for this, off top of
my head (without looking at your syntax):

ip set group 10 ppp*

And equivalent to "ifconfig ppp*" so i dont list 10K interfaces
ip list group 10 or pass any 5K messages to user space

cheers,
jamal

