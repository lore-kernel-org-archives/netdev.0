From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 12:10:00 +0200
Message-ID: <20100915101000.GB28016@redhat.com>
References: <20100914152231.GA13105@redhat.com>
 <1284480025.13351.49.camel@localhost.localdomain>
 <20100914162952.GB13560@redhat.com>
 <1284483745.13351.71.camel@localhost.localdomain>
 <20100914182707.GB15549@redhat.com>
 <1284490143.13351.82.camel@localhost.localdomain>
 <20100914190156.GA16037@redhat.com>
 <1284492983.13351.95.camel@localhost.localdomain>
 <20100915051241.GA25340@redhat.com>
 <1284531675.24603.259.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1284531675.24603.259.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 14, 2010 at 11:21:15PM -0700, Shirley Ma wrote:
> On Wed, 2010-09-15 at 07:12 +0200, Michael S. Tsirkin wrote:
> > Yes, I agree this patch is useful for demo purposes:
> > simple, and shows what kind of performance gains
> > we can expect for TX. 
> 
> Any other issue you can see in this patch beside vhost descriptors
> update?

Another issue is that macvtap can be bound to almost
anything, including e.g. a tap device or a bridge,
which might hang on to skb fragments for unlimited time.
Zero copy TX won't easily work there.
I can imagine either somehow triggering a data copy after the
fact (hard), or detecting such devices and avoiding
zero copy (unfortunate for guest to guest, and drivers
will need tuning).

>  Don't you think once I address vhost_add_used_and_signal update
> issue, it is a simple and complete patch for macvtap TX zero copy?
> 
> Thanks
> Shirley

I like the fact that the patch is simple. Unfortunately
I suspect it'll stop being simple by the time it's complete :)

-- 
MST
