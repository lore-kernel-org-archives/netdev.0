From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Tue, 3 Nov 2009 15:01:56 -0500
Message-ID: <20091103200155.GQ8227@kvack.org>
References: <20091101163130.GA7911@kvack.org> <20091103035058.GA19515@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755352AbZKCUCI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091103035058.GA19515@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 02, 2009 at 07:50:58PM -0800, Greg KH wrote:
> On Sun, Nov 01, 2009 at 11:31:30AM -0500, Benjamin LaHaise wrote:
> > Use an rbtree in sysfs_dirent to speed up file lookup times
> > 
> > Systems with large numbers (tens of thousands and more) of network 
> > interfaces stress the sysfs code in ways that make the linear search for 
> > a name match take far too long.  Avoid this by using an rbtree.
> 
> What kind of speedups are you seeing here?  And do these changes cause a
> memory increase due to the structure changes which outweigh the
> speedups?

Depends on the number of interfaces being created.  Without the patch, 
interface creation time tends to double or worse for every 5,000-10,000 
additional network interfaces.

> What kind of test are you doing to reproduce this?

I'm creating 30,000+ network interfaces, with the goal being 100,000.  
With other hacks in the tree to get around the sysctl and procfs scaling 
issues, as well as disabling things like NetworkManager, the results look 
as follows:

	Interfaces	no-rb	rbtree	rbtree+list
	0-5,000		13.8s	14.0s	13.0s
	5,000-10,000	20.0s	17.4s	14.4s
	10,000-15,000	27.3s	24.1s	16.9s
	15,000-20,000	36.3s	32.2s	19.7s
	20,000-25,000	45.2s	40.0s	22.9s
	25,000-30,000	54.2s	48.2s	26.6s
	30,000-35,000	63.9s	54.9s	30.7s

Thoughts?

		-ben
