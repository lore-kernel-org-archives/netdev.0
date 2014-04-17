From: Daniel J Walsh <dwalsh@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup
 path
Date: Thu, 17 Apr 2014 08:41:15 -0700
Message-ID: <534FF61B.4010901@redhat.com>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com> <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com> <20140416.085743.1614257692560892039.davem@davemloft.net> <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com> <1397664837.19767.410.camel@willson.li.ssimo.org> <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com> <20140416180642.GG31074@redhat.com> <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com> <20140416185936.GJ31074@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Simo Sorce <ssorce@redhat.com>, David Miller <davem@davemloft.net>,
	Tejun Heo <tj@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Vivek Goyal <vgoyal@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140416185936.GJ31074@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 04/16/2014 11:59 AM, Vivek Goyal wrote:
> On Wed, Apr 16, 2014 at 11:13:31AM -0700, Andy Lutomirski wrote:
>> On Wed, Apr 16, 2014 at 11:06 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
>>> On Wed, Apr 16, 2014 at 09:31:25AM -0700, Andy Lutomirski wrote:
>>> I am not sure how same issue with happen with cgroups. In the case of
>>> socket example, you are forcing a setuid program to write to standard
>>> output and that setuid program will run in same cgroup as caller and
>>> will have same cgroup as caller. So even if somebody was using cgroup
>>> information for authentication, atleast in this particular case it
>>> will not be a problem. Both unpriviliged and priviliged programs has
>>> same cgroups.
>>>
>> I'm not sure that there's an actual attackable program.  But I also
>> see no reason to be convinced that there isn't one, and the problem
>> can easily be avoided by requiring programs to explicitly ask to send
>> their cgroup.
> If you can't prove that there is something fundamentally wrong with
> passing cgroup info to receiver, there is no reason to block these
> patches either.
>
> We can't fix the problems which we can't see. You are saying that I 
> don't know what kind of problem can happen due to cgroup passing. Still
> that does not mean none of the problems exist. So let us not pass cgroup
> info by default and ask client to opt in.
>
> I don't think this is a very convincing argument.
>
> To me, if we can't see anything fundamentally wrong with passing cgroup
> info, we should take these patches in. And once we figure out that there
> is are problematic use cases, then implement SO_NOPASSCGROUP and
> SO_NOPEERCRED  and allow problematic clients to opt out.
>
> Thanks
> Vivek
The two use cases for this patch are:

1 Logging, to make sure the cgroup information gets correctly attributed
to the caller. 

2 Potentially reveal different information to the caller based on the
cgroup information. 

Imagine you want to set up an apache web server that is going to use
sssd for authentication data.  You might want to reveal a limited set of
users to the apache service process based on the fact that it is running
in the apache.service.slice.  If the apache service does the equivalent
of getent passwd I want to give it different information then say sshd
did the same calls.
