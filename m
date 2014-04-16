From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 1/2] net: Implement SO_PEERCGROUP
Date: Tue, 15 Apr 2014 20:22:45 -0400
Message-ID: <20140416002245.GB5035@redhat.com>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
 <1397596546-10153-2-git-send-email-vgoyal@redhat.com>
 <CALCETrV7ZwWtCJQ2uF3WmctTj0qBkh2MRQS4uy9vPhP0zKPYrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Simo Sorce <ssorce@redhat.com>, lpoetter@redhat.com,
	kay@redhat.com, dwalsh@redhat.com
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrV7ZwWtCJQ2uF3WmctTj0qBkh2MRQS4uy9vPhP0zKPYrQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 15, 2014 at 02:54:02PM -0700, Andy Lutomirski wrote:
> On Tue, Apr 15, 2014 at 2:15 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> > Implement SO_PEERCGROUP along the lines of SO_PEERCRED. This returns the
> > cgroup of first mounted hierarchy of the task. For the case of client,
> > it represents the cgroup of client at the time of opening the connection.
> > After that client cgroup might change.
> >
> > This works only for unix stream sockets.
> 
> I still don't understand why this is useful when SCM_CGROUP exists.

I think this is more lightweight as compared to SCM_CGROUP. Information
is stored per connection as opposed to per message.

So if user space has created a system where unpriviliged processed have
been locked in cgroups and they can't escape those cgroups, then
SO_PEERCRED should be sufficient and one does not have to use SCM_CGROUP.

Thanks
Vivek
