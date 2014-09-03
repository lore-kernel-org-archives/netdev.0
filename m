From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process is
 runnable
Date: Wed, 3 Sep 2014 12:59:39 +0300
Message-ID: <20140903095939.GA8929@redhat.com>
References: <53F6F14B.1030609@redhat.com>
 <20140822074224.GB7372@gmail.com>
 <53FFEEC0.4000304@redhat.com>
 <540414AB.9000004@linux.intel.com>
 <54053998.4040604@redhat.com>
 <54056076.2030603@linux.intel.com>
 <20140902083124.GB10356@redhat.com>
 <5406B9E6.6050103@linux.intel.com>
 <5406C443.5030109@redhat.com>
 <20140903093605.GD4783@worktop.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140903093605.GD4783@worktop.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 03, 2014 at 11:36:05AM +0200, Peter Zijlstra wrote:
> On Wed, Sep 03, 2014 at 03:33:23PM +0800, Jason Wang wrote:
> > A new issue is for virt users. I implement busy polling for virtio-net
> > but we don't want one vcpu monopoly the cpu if there's some tasks on
> > other vcpus. We may need some hint from host to guest to let it exit the
> > loop if needed.
> 
> Aw god.. virt nonsense is wrecking things again.

I don't see a reason to bring virt up here.  Original patch shows
improvement with a simple loopback netperf test.

Some people like the linux kernel so much, they want to run many
instances of it on the same CPU. Understandable.
So of course everything is then magnified x2 as you
are running two schedulers and two networking stacks,
but let's focus on the important thing which is
better interaction between busy polling and the linux scheduler.

-- 
MST
