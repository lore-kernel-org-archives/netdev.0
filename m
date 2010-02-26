From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Fri, 26 Feb 2010 12:35:56 -0800
Message-ID: <m1k4tzwx8z.fsf@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	<m1r5obbu2w.fsf@fess.ebiederm.org> <1266966581.3973.675.camel@bigi>
	<m1pr3t2fvl.fsf_-_@fess.ebiederm.org> <4B86EC45.3060005@free.fr>
	<m1mxyx0yv7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1mxyx0yv7.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Thu\, 25 Feb 2010 13\:49\:48 -0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> No, the plan is only one namespace at a time.

Looking at this a bit more I am frustrated and relieved.

I was looking at what it would take to join an arbitrary mount
namespace and I realized it is completely non-obvious what fs->root
and fs->pwd should be set to.

If I leave them untouched the new mount namespace is useless,
as all path lookups will give results in a different mount namespace,
so not even mount or umount can be used.

I can not change fs->root to mnt_ns->root as that is rootfs and there
is always something mounted on top so I can not use that.

In comparison an unshare of the mount namespace doesn't have to move
fs->root or fs->pwd at all and only has to update their mounts to
the corresponding mounts in the new mount namespace.

I might be able to find the topmost root filesystem and put at least
root there, but I'm not particularly fond of that option.

Eric





