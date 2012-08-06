From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/13] SCTP: Enable netns
Date: Mon, 06 Aug 2012 11:20:08 -0700
Message-ID: <87mx27rig7.fsf@xmission.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jan Ariyasu <jan.ariyasu@hp.com>
To: Jan Ariyasu <jan.ariyasu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com> (Jan
	Ariyasu's message of "Sat, 4 Aug 2012 15:30:37 -0600")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Ariyasu <jan.ariyasu@gmail.com> writes:

> The following set of patches enable network-namespaces for the SCTP protocol.
>
> The multitude of global parameters are stored in a net_generic
> structure, and the bulk of the patches enable the protocol to access
> the parameters on a per-namespace basis.  The first five patches
> enable netns handling of the protocol, procfs and sysfs.

I am going to do something to muddy the waters here, that I had hoped to
avoid when I saw your patchset.

A few weeks ago I wanted to play with sctp and also made a network
namespace enabled version.  I am not deeply attached to my changes,
however when comparing the differences I realized that your code fails
to make the lookup of associations per network namespace.

Given that we only have source and destination port to lookup
assoications by this almost guarantees one network namespace can
accidentially use the association of another network namespace meerly
by reusing the same ports.

The downside with my version is that it does not make all of the sctp
tunables per network namespace the way yours does, but making all of
the tunables per network namespace should be straight forward from
my base.

My patchset also misses some nice to haves like making the association
id allocation per network namespace.  It is not important for
correctness of the code but it might allow an information leak between
namespaces.

So Jan I am going to send my patchset and hopefully you can rebase your
changes to make all of the tunables per network namespace on top of
mine.

Since my patchset is half the size of your I think that is the most
reasonable way to go.

Eric
