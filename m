From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in skb_copy_bits
Date: Sun, 30 Jun 2013 00:50:50 -0700
Message-ID: <1372578650.3301.305.camel@edumazet-glaptop>
References: <51CBAA48.3080802@oracle.com>
	   <1372311118.3301.214.camel@edumazet-glaptop>
	 <51CD0E67.4000008@oracle.com>
	   <1372402340.3301.229.camel@edumazet-glaptop>
	  <1372412262.3301.251.camel@edumazet-glaptop> <51CE1E19.3020108@oracle.com>
	 <1372490428.3301.300.camel@edumazet-glaptop> <51CF7B31.8050408@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"zheng.x.li@oracle.com" <zheng.x.li@oracle.com>,
	Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51CF7B31.8050408@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-06-30 at 08:26 +0800, Joe Jin wrote:

> So far we suspected it caused by iscsi called sendpage(), and later page
> be unmapped but still trying copy skb. We'll try to disable sg to see if
> help or no.

sendpage() should increment page refcounts for every page frag of an
skb, therefore page should not be unmapped.

Of course userland can either rewrite the content, or unmap() the page,
but the underlying page cannot be freed as long skb is not freed.
