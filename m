From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net v3 2/4] net: add rx_nohandler stat counter
Date: Mon, 8 Feb 2016 13:32:54 -0500
Message-ID: <20160208183254.GB4566@redhat.com>
References: <1454370667-2328-1-git-send-email-jarod@redhat.com>
 <1454370667-2328-3-git-send-email-jarod@redhat.com>
 <20160207113732.25a88cc4@xeon-e3>
 <20160207.144648.750890874940574761.davem@davemloft.net>
 <1454876368.7627.350.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454876368.7627.350.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 07, 2016 at 12:19:28PM -0800, Eric Dumazet wrote:
> On Sun, 2016-02-07 at 14:46 -0500, David Miller wrote:
> 
> > > Why was this userspace ABI change allowed?
> > > The stats structure is exposed to user space via netlink
> > > and changing the size of responses will break iproute2 commands.
> 
> I do not think it breaks anything.
> 
> iproute2 always assumed kernel was sending at least 23 u64, and does not
> check at all if the kernel sends more. (or less, so iproute2 can print
> garbage if kernel is malicious)
> 
> an iproute2 patch will be needed to automatically detect if new kernels
> are sending more data and print it accordingly.

My TODO list did include poking at iproute2 to expose the new info, I can
take a closer look for possible issues as well, but...

> > > The code will be expecting one size and the response will vary and
> > > break existing code.  Yes, the code should check the size
> > > of the response, but it doesn't and I am sure iproute2 is not
> > > the only code that does this.
> > 
> > Jarod, please look into this.
> 
> Running latest net-next, and old iproute2 is just fine.

...I haven't run into anything that didn't work with current iproute2
either while testing out functionality of these patches. If there's
something in particular that seems most suspect that I perhaps simply
haven't tried, I can give that a go as well.

In any case, I'm definitely due to take a look at iproute2 as it relates
to this patchset.

-- 
Jarod Wilson
jarod@redhat.com
