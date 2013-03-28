From: Benoit Lourdelet <blourdel@juniper.net>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 15:21:48 +0000
Message-ID: <CD7A1D9A.78BA%blourdel@juniper.net>
References: <20130328150410.GA22789@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:46151 "EHLO
	exprod7og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755479Ab3C1PXj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 11:23:39 -0400
Received: from mail130-co1 (localhost [127.0.0.1])	by
 mail130-co1-R.bigfish.com (Postfix) with ESMTP id 62BADD60474	for
 <netdev@vger.kernel.org.FOPE.CONNECTOR.OVERRIDE>; Thu, 28 Mar 2013 15:21:54
 +0000 (UTC)
In-Reply-To: <20130328150410.GA22789@sergelap>
Content-Language: en-US
Content-ID: <25343ABC19FCB641A1FF04B144EE1AFA@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I use, for each container :

lxc-start -n lwb2001 -f /var/lib/lxc/lwb2001/config -d

I created the containers with lxc-ubuntu -n lwb2001

Benoit

On 28/03/2013 16:04, "Serge Hallyn" <serge.hallyn@ubuntu.com> wrote:

>Quoting Benoit Lourdelet (blourdel@juniper.net):
>> Hello,
>> 
>> My test consists in starting small containers (10MB of RAM ) each. Each
>> container has 2x physical VLAN interfaces attached.
>
>Which commands were you using to create/start them?
>
>> lxc.network.type = phys
>> lxc.network.flags = up
>> lxc.network.link = eth6.3
>> lxc.network.name = eth2
>> lxc.network.hwaddr = 00:50:56:a8:03:03
>> lxc.network.ipv4 = 192.168.1.1/24
>> lxc.network.type = phys
>> lxc.network.flags = up
>> lxc.network.link = eth7.3
>> lxc.network.name = eth1
>> lxc.network.ipv4 = 2.2.2.2/24
>> lxc.network.hwaddr = 00:50:57:b8:00:01
>> 
>> 
>> 
>> With initial iproute2 , when I reach around 1600 containers, container
>> creation almost stops.It takes at least 20s per container to start.
>> With patched iproutes2 , I have started 4000 containers at a rate of 1
>>per
>> second w/o problem. I have 8000 clan interfaces configured on the host
>>(2x
>> 4000).
>> 
>> 
>> Regards
>> 
>> Benoit
>> 
>> On 28/03/2013 14:36, "Serge Hallyn" <serge.hallyn@ubuntu.com> wrote:
>> 
>> >Quoting Eric W. Biederman (ebiederm@xmission.com):
>> >> Serge Hallyn <serge.hallyn@ubuntu.com> writes:
>> >> 
>> >> > Quoting Eric W. Biederman (ebiederm@xmission.com):
>> >> >> Serge Hallyn <serge.hallyn@ubuntu.com> writes:
>> >> >> 
>> >> >> > Quoting Eric W. Biederman (ebiederm@xmission.com):
>> >> >> >> Stephen Hemminger <stephen@networkplumber.org> writes:
>> >> >> >> 
>> >> >> >> > If you need to do lots of operations the --batch mode will be
>> >>significantly faster.
>> >> >> >> > One command start and one link map.
>> >> >> >> 
>> >> >> >> The problem in this case as I understand it is lots of
>>independent
>> >> >> >> operations. Now maybe lxc should not shell out to ip and
>>perform
>> >>the
>> >> >> >> work itself.
>> >> >> >
>> >> >> > fwiw lxc uses netlink to create new veths, and picks random
>>names
>> >>with
>> >> >> > mktemp() ahead of time.
>> >> >> 
>> >> >> I am puzzled where does the slownes in iproute2 come into play?
>> >> >
>> >> > Benoit originally reported slowness when starting >1500
>>containers.  I
>> >> > asked him to run a few manual tests to figure out what was taking
>>the
>> >> > time.  Manually creating a large # of veths was an obvious test,
>>and
>> >> > one which showed poorly scaling performance.
>> >> 
>> >> Apparently iproute is involved somehwere as when he tested with a
>> >> patched iproute (as you asked him to) the lxc startup slowdown was
>> >> gone.
>> >> 
>> >> > May well be there are other things slowing down lxc of course.
>> >> 
>> >> The evidence indicates it was iproute being called somewhere...
>> >
>> >Benoit can you tell us exactly what test you were running when you saw
>> >the slowdown was gone?
>> >
>> >-serge
>> >
>> 
>> 
>
