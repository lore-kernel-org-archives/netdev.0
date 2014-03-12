From: Simo Sorce <ssorce@redhat.com>
Subject: Re: [PATCH 0/2][V2] net: Implement SO_PEERCGROUP to get cgroup of
 peer
Date: Wed, 12 Mar 2014 16:59:30 -0400
Message-ID: <1394657970.32465.200.camel@willson.li.ssimo.org>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
	 <5320C9FC.6070301@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, tj@kernel.org, jkaluza@redhat.com,
	lpoetter@redhat.com, kay@redhat.com
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5320C9FC.6070301@amacapital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-12 at 13:56 -0700, Andy Lutomirski wrote:
> On 03/12/2014 01:46 PM, Vivek Goyal wrote:
> > Hi,
> > 
> > This is V2 of patches. Fixed the function format issue and also I was using
> > CONFIG_CGROUP instead of CONFIG_CGROUPS. That led to crash at boot. Fixed that.
> > 
> > Some applications like sssd want to know the cgroup of connected peer over
> > unix stream socket. They want to use this information to map the cgroup to 
> > the container client belongs to and then decide what kind of policies apply
> > on the container.
> > 
> 
> Can you explain what the use case is?

External programs contacted from inside a container want to know 'who'
is contacting them. Whee 'who' is determined by the cgroup their put in.
This way these external programs can apply appropriate policy associated
with the specific 'marking' cgroup.

> My a priori opinion is that this is a terrible idea.  cgroups are a
> nasty interface, and letting knowledge of cgroups leak into the programs
> that live in the groups (as opposed to the cgroup manager) seems like a
> huge mistake to me.

I am not sure where you are going, the program that want's to know about
the cgroup is outside the group.

> If you want to know where in the process hierarchy a message sender is,
> add *that* and figure out how to fix the races (it shouldn't be that hard).

What is *that* here ?

Simo.
