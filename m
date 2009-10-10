From: "Paul Moore" <paul.moore@hp.com>
Subject: Re: Real networking namespace
Date: Sat, 10 Oct 2009 17:40:27 -0400
Message-ID: <7264578776.939663627@hp.com>
References: <20091009190820.0a0f09c2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: sds@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	viro@zeniv.linux.org.uk, netdev@vger.kernel.org, jmorris@namei.org
To: shemminger@linux-foundation.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091009190820.0a0f09c2@nehalam>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------- Original message -------
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: sds@tycho.nsa.gov, linux-security-module@vger.kernel.org, 
> viro@zeniv.linux.org.uk, netdev@vger.kernel.org, jmorris@namei.org
> Sent: 10/9,  22:08
>
> On Fri, 9 Oct 2009 18:12:15 -0400
> Paul Moore <paul.moore@hp.com> wrote:
>
>> On Friday 09 October 2009 12:44:52 pm Stephen Smalley wrote:
>> > On Fri, 2009-10-09 at 12:37 -0400, Stephen Smalley wrote:
>> > > On Fri, 2009-10-09 at 08:38 -0700, Stephen Hemminger wrote:
>> > > > The existing networking namespace model is unattractive for what I
>> > > > want, has anyone investigated better alternatives?
>> > > >
>> > > > I would like to be able to allow access to a network interface and
>> > > > associated objects (routing tables etc), to be controlled by 
>> Mandatory
>> > > > Access Control API's. I.e grant access to eth0 and to only certain
>> > > > processes.  Some the issues with the existing models are:
>> > > >   * eth0 and associated objects don't really exist in filesystem 
>> so
>> > > >     not subject to LSM style control (SeLinux/SMACK/TOMOYO)
>>
>> As Stephen points out, SELinux does have the ability to assign security 
>> labels
>> to network interfaces, check out the 'semanage' command.  A while back I 
>> wrote
>> up something about the SELinux network "ingress/egress" access controls:
>>
>>  * http://paulmoore.livejournal.com/2128.html
>
> I was hoping to be able to not have inaccessible interfaces visible,
> is it possible to not have interfaces show up in commands like:
>   ip link show
> or sysfs?

I haven't looked at the code for 'ip' but I'm pretty sure it uses netlink 
to configure the kernel, yes?  If that is the case, no I don't believe any 
of the current LSMs provide that level of granularity (netlink, generic 
netlink in particular, is a bit of a problem spot at the moment).  As for 
sysfs, I don't believe we label the interface related files based on their 
semanage labels but I could be wrong - we've got plenty of good people 
already working on fs labeling so I spend most of my  time worrying about 
network labeling.

--
paul moore
linux @ hp

