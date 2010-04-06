From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] A device for zero-copy based on KVM virtio-net.
Date: Tue, 6 Apr 2010 10:49:02 +0300
Message-ID: <20100406074901.GB9662@redhat.com>
References: <20100308112849.GI7482@redhat.com> <1270114038-5048-1-git-send-email-xiaohui.xin@intel.com> <20100401110841.GE3323@redhat.com> <97F6D3BD476C464182C1B7BABF0B0AF5C17B5BB9@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>,
	"yzhao81@gmail.com" <yzhao81@gmail.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <97F6D3BD476C464182C1B7BABF0B0AF5C17B5BB9@shzsmsx502.ccr.corp.intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 06, 2010 at 01:41:37PM +0800, Xin, Xiaohui wrote:
> Michael,
> >> 
> >>For the DOS issue, I'm not sure how much the limit get_user_pages()
> >> can pin is reasonable, should we compute the bindwidth to make it?
> 
> >There's a ulimit for locked memory. Can we use this, decreasing
> >the value for rlimit array? We can do this when backend is
> >enabled and re-increment when backend is disabled.
> 
> I have tried it with rlim[RLIMIT_MEMLOCK].rlim_cur, but I found
> the initial value for it is 0x10000, after right shift PAGE_SHIFT,
> it's only 16 pages we can lock then, it seems too small, since the 
> guest virito-net driver may submit a lot requests one time.
> 
> 
> Thanks
> Xiaohui

Yes, that's the default, but system administrator can always increase
this value with ulimit if necessary.

-- 
MST
