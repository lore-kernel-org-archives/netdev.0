From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Wed, 23 Apr 2014 12:45:37 -0400
Message-ID: <20140423164537.GD24651@redhat.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
 <1397596546-10153-3-git-send-email-vgoyal@redhat.com>
 <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com>
 <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Daniel Walsh <dwalsh@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, Simo Sorce <ssorce@redhat.com>,
	cgroups@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	kay@redhat.com, Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2014 at 08:47:54PM -0700, Andy Lutomirski wrote:

[..]
> Here's an attack against SO_PASSCGROUP, as you implemented it: connect
> a socket and get someone else to write(2) to it.  This isn't very
> hard.  Now you've impersonated.

If this is a problem then I think kernel requires fixing. Because kernel
will apply all resource management policies based on the cgroup at write(2)
time and not based on open() time.

For example, blkio throttling policies. If you get a process in other
cgroup to read/write to an fd, then IO throttling rules of that cgroup
are applied and it does not matter who opened fd in first place.

So SO_PASSCGROUP is not exactly same as SO_PASSCRED in that sense. If
there are issues w.r.t authorization/authentication etc, then that
should be a recommendation to user space that don't use cgroup info
for unsafe cases.

Thanks
Vivek
