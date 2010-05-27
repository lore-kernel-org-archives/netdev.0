From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: issue about virtio-net driver to suppoprt vhost mergeable buffer
 with zero-copy to support PS mode
Date: Thu, 27 May 2010 09:21:02 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D790B7958E740@shsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "mst@redhat.com" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,
I'm now looking into the vhost mergeable buffer, and I tried to use it to support PS mode with zero-copy. And I found an issue there that I have to modify the guest virito-net driver.

When guest virtio-net driver submits mergeable buffers, it submits multiple pages outside. In zero-copy case, vhost cannot know which page is used to put header, and which page is used to put payload. Then vhost can only reserves 12 bytes for each page. That means, the page_offset of the payload DMAed into the guest buffer is always 12 bytes. But guest virtio-net driver always use offset 0 to put the data (See receive_mergeable()). That's where the zero-copy use mergeable buffer must modify.

Have I missed something here? And how do you think about it?

Thanks 
Xiaohui 
