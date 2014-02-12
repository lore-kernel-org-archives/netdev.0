From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net 1/3] kref: add kref_sub_return
Date: Wed, 12 Feb 2014 08:56:30 -0800
Message-ID: <20140212165630.GA22991@kroah.com>
References: <1392222846-26699-1-git-send-email-mst@redhat.com>
	<1392222846-26699-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, Joern Engel <joern@logfs.org>,
	Anatol Pomozov <anatol.pomozov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com,
	davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1392222846-26699-2-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 12, 2014 at 06:38:21PM +0200, Michael S. Tsirkin wrote:
> It is sometimes useful to get the value of the reference count after
> decrement.
> For example, vhost wants to execute some periodic cleanup operations
> once number of references drops below a specific value, before it
> reaches zero (for efficiency).

You should never care about what the value of the kref is, if you are
using it correctly :)

So I really don't want to add this function, as I'm sure people will use
it incorrectly.  You should only care if the reference drops to 0, if
not, then your usage doesn't really fit into the "kref" model, and so,
just use an atomic variable.

I really want to know why it matters for "efficiency" that you know this
number.  How does that help anything, as the number could then go up
later on, and the work you did at a "lower" number is obsolete, right?

thanks,

greg k-h
