From: Eric Paris <eparis@redhat.com>
Subject: Re: module loading permissions and request_module permission
 inconsistencies
Date: Mon, 10 Aug 2009 16:48:59 -0400
Message-ID: <1249937339.2501.80.camel@dhcp231-106.rdu.redhat.com>
References: <1249933513.2501.58.camel@dhcp231-106.rdu.redhat.com>
	 <20090810202308.GA15390@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, sds@tycho.nsa.gov,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kees@ubuntu.com, morgan@kernel.org, serue@us.ibm.com,
	casey@schaufler-ca.com, dwlash@redhat.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753223AbZHJUuR@vger.kernel.org>
In-Reply-To: <20090810202308.GA15390@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-08-10 at 16:23 -0400, Neil Horman wrote:
> On Mon, Aug 10, 2009 at 03:45:13PM -0400, Eric Paris wrote:

> > 1) remove CAP_SYS_MODULE from the networking code and instead check
> > CAP_NET_ADMIN.  Maybe CAP_NET_ADMIN is already being checked and I'll
> > just remove the capable call altogether but at least I can more
> > intelligently limit the powers of these processes and they will still be
> > root limited according to DAC permissions like they are today.
> > 
> Would this have any adverse effect on how user space sees this working.
> Intuitively I would think that if you wanted to load a module (directly or
> indirectly, via an iptables command or whatnot), you would need CAP_SYS_MODULE
> capabilities on the calling process, not just CAP_NET_ADMIN.  I honestly don't
> know the answer here, I'm just raising the question.

While that might make intuitive sense, it's actually proving to be a bad
idea to use the same capability for direct and indirect module loading
(especially considering we have 125 other places in the kernel where you
can do indirect module loading without any security check)  And believe
me, if someone suggests I move a CAP_SYS_MODULE check down into
__request_module I'll scream about what a horrible idea that is (and
then laugh at them behind their back).

While I think there should be some check in __request_module I don't
think it should be CAP_SYS_MODULE.

CAP_NET_ADMIN at least limits us to root and in all reality to the same
situation everyone is in today.  I just checked every single selinux
domain that grants CAP_SYS_MODULE already grants CAP_NET_ADMIN, so we
can somewhat safely say that nothing (on a fedora system at least) would
break with this change.

-Eric
