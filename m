From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V7 4/4 net-next] vhost: vhost TX zero-copy support
Date: Wed, 06 Jul 2011 12:28:16 -0700
Message-ID: <1309980496.10209.2.camel@localhost.localdomain>
References: <1306611267.5180.97.camel@localhost.localdomain>
	 <20110629091300.GC14627@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110629091300.GC14627@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-06-29 at 12:13 +0300, Michael S. Tsirkin wrote:
> On Sat, May 28, 2011 at 12:34:27PM -0700, Shirley Ma wrote:
> > Hello Michael,
> > 
> > In order to use wait for completion in shutting down, seems to me
> > another work thread is needed to call vhost_zerocopy_add_used,
> 
> Hmm I don't see vhost_zerocopy_add_used here.

I put the call in vhost_set_vring.

> 
> > it seems
> > too much work to address a minor issue here. Do we really need it?
> 
> Assuming you mean vhost_zerocopy_signal_used, here's how I would do
> it:
> add a kref and a completion, signal completion in kref_put
> callback, when backend is set - kref_get, on cleanup,
> kref_put and then wait_for_completion_interruptible.
> Where's the need for another thread coming from?
> 
> If you like, post a patch with busywait + a FIXME comment,
> and I can write up a patch on top.

I might not have time  to finish this during my vacation, so I am
putting busywait + a FIXME comment.

> (BTW, ideally the function that does the signalling should be
> in core networking bits so that it's still around
> even if the vhost module gets removed). 

Thanks
Shirley
