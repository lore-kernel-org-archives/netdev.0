From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [BUG?] bridge_id not getting set for bridges created
	with
Date: Thu, 24 Apr 2014 21:06:17 +0900
Message-ID: <1398341177.4171.11.camel@ubuntu-vm-makita>
References: <CAG-2HqVnWXu2dW=Su6DDxDzgg3cLSvTMu5Sf=Eq+YUv4P1d4NQ@mail.gmail.com>
	<CAG-2HqU2f+4i3ttLSeitwr15=cVyin9VT+UrQvKC9pMV04fW7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, bridge <bridge@lists.linux-foundation.org>,
	"C. R. Oldham" <cr@saltstack.com>
To: Tom Gundersen <teg@jklm.no>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAG-2HqU2f+4i3ttLSeitwr15=cVyin9VT+UrQvKC9pMV04fW7Q@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-04-21 at 22:56 +0200, Tom Gundersen wrote:
> On Mon, Apr 21, 2014 at 9:33 PM, Tom Gundersen <teg@jklm.no> wrote:
> > Hi,
> >
> > If IFLA_ADDRESS is set when creating a bridge over netlink, e.g.
> >
> > # ip link add test-bridge address b6:83:a2:b3:2f:0e type bride
> >
> > the bridge id is not set:
> >
> > # brctl show
> > bridge name    bridge id        STP enabled    interfaces
> > bridge1        8000.000000000000    no
> 
> My example was incomplete. To see the bug one should of course first
> add an interface to the bridge:
> 
> # brctl addif bridge1 eth0
> 
> 
> and observe that the bridge id remains unset:
> 
> # brctl show
> bridge name    bridge id        STP enabled    interfaces
> bridge1        8000.000000000000    no            eth0
> 
> 
> 
> If bridge1 had been created without specifying the mac address the
> result is as expected:
> 
> # brctl show
> bridge name    bridge id        STP enabled    interfaces
> bridge1        8000.28d244547cdb    no            eth0
> 

Hi.

This seems to be a bug.
What's worse is that local fdb entry won't be created and we will not be
able to receive frames on the bridge device...

rtnl_create_link() doesn't call ndo_set_mac_address but populates
dev->dev_addr by itself. I'm not sure if it is safe to call
ndo_set_mac_address in this function (maybe affects other drivers).  I
think this can be handled in bridge codes (br_link_ops->newlink).

I'm submitting a patch to fix this.

Thanks,
Toshiaki Makita
