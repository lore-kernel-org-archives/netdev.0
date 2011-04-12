From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Tue, 12 Apr 2011 14:25:34 -0700 (PDT)
Message-ID: <20110412.142534.183049889.davem@davemloft.net>
References: <20110409101514.GA4262@albatros>
	<20110412050659.GA14129@openwall.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, peak@argo.troja.mff.cuni.cz,
	kees.cook@canonical.com, dan.j.rosenberg@gmail.com,
	eugene@redhat.com, nelhage@ksplice.com, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: solar@openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110412050659.GA14129@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Solar Designer <solar@openwall.com>
Date: Tue, 12 Apr 2011 09:06:59 +0400

> On Sat, Apr 09, 2011 at 02:15:14PM +0400, Vasiliy Kulikov wrote:
>> This patch adds IPPROTO_ICMP socket kind.  It makes it possible to send
>> ICMP_ECHO messages and receive the corresponding ICMP_ECHOREPLY messages
>> without any special privileges.  In other words, the patch makes it
>> possible to implement setuid-less and CAP_NET_RAW-less /bin/ping.  In
>> order not to increase the kernel's attack surface (in case of
>> vulnerabilities in the newly added code), the new functionality is
>> disabled by default, but is enabled at bootup by supporting Linux
>> distributions, optionally with restriction to a group or a group range
> ...
>> For Openwall GNU/*/Linux it is the last step on the road to the
>> setuid-less distro.
> 
> More correctly, it _was_ the last step - we've already taken it, so a
> revision of the patch (against OpenVZ/RHEL5 kernels) is currently in use.
> 
> We would really like this accepted into mainline, which is why Vasiliy
> spends extra effort to keep the patch updated to current mainline
> kernels and re-test it.  If there are any comments/concerns/objections,
> we'd be happy to hear those.
> 
>> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> 
> Acked-by: Solar Designer <solar@openwall.com>

I have no fundamental objections to this change and I'll be happy to
apply it after we iron out a few details.

First, please get rid of the debug option, we have pr_debug() which can
be dynamically turned on and off at run time these days.

Second, if this is a bonafide core facility we'd like everyone to use,
let's make it so.  I want it so that every ping binary can expect this
facility to be there if the kernel is new enough.

So let's get rid of the config option.

Third, either we trust this code or we do not.  If we are OK with a
user application spamming whatever they wish out of a datagram UDP
socket, they can do no more harm with this thing unless there are
bugs.

The group range thing I also consider hackish.  In my opinion two
other approaches seem more reasonable:

1) On/Off sysctl, default to ON.  This is to handle the "oh crap
   there's a really bad bug discovered in this thing" situations.

2) A single group ID, if zero it means "all groups" else it limits
   the facility to specific groups.

I would mention capabilities, but probably that's undesirable for
something like this as it creeps us back to the original problem
this is trying to resolve.

Finally, longer term, I'd really like to see ipv6 support for this
feature as well.  I absolutely am not requiring that ipv6 get
worked on right now just to apply the ipv4 variant.

So let's sort out the ipv4 side issues so I can get this into the
net-next-2.6 tree and people can start testing it.

Thanks.
