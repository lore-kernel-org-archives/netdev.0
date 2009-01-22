From: Jonathan Day <imipak@yahoo.com>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal  firewalls"
Date: Thu, 22 Jan 2009 09:08:04 -0800 (PST)
Message-ID: <5807.2433.qm@web31502.mail.mud.yahoo.com>
References: <e7d8f83e0901220546l90987a7ic3d7a7c98b14f07a@mail.gmail.com>
Reply-To: imipak@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rmeijer@xs4all.nl, Casey Schaufler <casey@schaufler-ca.com>,
	Samir Bellabes <sam@synack.fr>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Peter Dolding <oiaohm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web31502.mail.mud.yahoo.com ([68.142.198.131]:38246 "HELO
	web31502.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753557AbZAVRIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 12:08:07 -0500
In-Reply-To: <e7d8f83e0901220546l90987a7ic3d7a7c98b14f07a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Thu, 1/22/09, Peter Dolding <oiaohm@gmail.com> wrote:
(snip)
> Worked with IPv4/6 hardware stacks.   Most of ones I have
> handled have
> had built in firewall processing.  Letting them feed
> directly into
> userspace becomes very uncontrollable very quickly. 
> Netfilter can be
> altered to operate like ALSA with hardware mixer.  Yes
> slower but you
> can filter.   Doing it at LSM you still have to place it in
> middle.
> Big issue with IPv4/6 hardware direct feeding into user
> space you have
> to get in middle to apply any forms of filters anyhow.

Ok, the LSM argument is certainly true, the direct feed I can see, and the ALSAfication of filtering is a highly intriguing solution that does answer the questions I had. From where I'm sitting (and I have no idea whatsoever whether that's remotely close to where anyone else sits), you've made a convincing argument.

(snip)
> Its not a completely different set of problems.   Please
> stop trying
> to draw lines in the sand between different groups.   Most
> critical
> thing for a firewall is that it works.

You'll get no argument from me on that.

(snip)
> Its just like the old idea that realtime OS's have
> nothing the same
> with supercomputers.   It turns out they have a lot in
> common lot of
> alterations to improve realtime support in Linux has
> increased
> supercomputer though put massively.

There, I 100% agree. Having worked for a supercomputer startup, I went through the bouncing-rocks-off-heads stage of getting people to see realtime and high-performance were not mutually-exclusive and did indeed have a lot in common.

> Desktop User needs a firewall that works correctly.   
> Server
> Administrators need the same.   Server Administrators do
> want simple
> to configure and be sure the firewall is right.   Same with
> Desktop
> users.

Again, you'll get no argument from me on that.

> When you get right down to it there is no much difference.

You've convinced me.

(snip)
> Linux network stack was very much designed with these evils
> in mind.
> Its highly modular it is the only way you can take this
> problem on.
> No matter what there will be events where you need to
> change the
> processing path completely by being modular you can.  
> These
> corner-cases are some of the reason why I keep on saying
> LSM is not
> the place.  Worst nightmares of the some of the
> corner-cases where
> some applications need treatment by a completely different
> processing
> stack to everything else.  LSM does not allow loading two
> modules/more
> safely without risking standing on the other LSM toes.
> 
> Basically if you cannot load multiable and assign them to
> different
> applications the design is not going to cut it in some of
> the corner
> cases.  Realtime vs Normal is fun enough.

This is probably the part of the argument that really made the case for me, as it covers both the weird paths problem and the modularity you need to make sure everything does get covered. The "everything gets covered" problem is the toughest part of any kind of access control on sockets and having gone hunting for as many weird and wonderful networking patches, I've seen some truly strange stuff.

> With clusters and shipping applications between processes
> supporting
> it gets a little pain in but.  Most likely putting the
> information in
> task credentials would be the sane solution then have when
> application
> is sent between machines its task credentials go with it.

Yes, it is a pain, and that makes it an excellent test. Almost anyone can write code that works under the most mainstream of normal conditions, so those simply aren't that useful in telling different methods apart. Things get fun when you start looking around the fringes, because that's when you really get an idea for when something can be readily extended or is going to be hitting a brick wall.

(snip)

It seems to me that the netfilter proponents have managed to solve everything I've thrown in their direction and have raised some good points regarding LSM. (And apologies if any of my prior posts got on anyone's nerves. I tend to be good at that.) This looks like it's going to be a fascinating and very well-argued debate, which can only be good news for whatever Linux ends up with.

Jonathan Day


      
