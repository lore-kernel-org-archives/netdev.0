From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net] bridge: Handle IFLA_ADDRESS correctly when
 creating bridge device
Date: Fri, 25 Apr 2014 17:18:45 +0900
Message-ID: <1398413925.3920.15.camel@ubuntu-vm-makita>
References: <CAG-2HqVnWXu2dW=Su6DDxDzgg3cLSvTMu5Sf=Eq+YUv4P1d4NQ@mail.gmail.com>
	<CAG-2HqU2f+4i3ttLSeitwr15=cVyin9VT+UrQvKC9pMV04fW7Q@mail.gmail.com>
	<1398341177.4171.11.camel@ubuntu-vm-makita>
	<1398341787.4171.16.camel@ubuntu-vm-makita>
	<CAG-2HqUhT+vbZfugfTYGzWt_qu45sKMaWXQ0uNg8SPzYNmG_5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	bridge <bridge@lists.linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, "C. R. Oldham" <cr@saltstack.com>
To: Tom Gundersen <teg@jklm.no>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAG-2HqUhT+vbZfugfTYGzWt_qu45sKMaWXQ0uNg8SPzYNmG_5A@mail.gmail.com>
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

On Thu, 2014-04-24 at 18:04 +0200, Tom Gundersen wrote:
> On Thu, Apr 24, 2014 at 2:16 PM, Toshiaki Makita
> <makita.toshiaki@lab.ntt.co.jp> wrote:
> > When bridge device is created with IFLA_ADDRESS, we are not calling
> > br_stp_change_bridge_id(), which leads to incorrect local fdb
> > management and bridge id calculation, and prevents us from receiving
> > frames on the bridge device.
> >
> > Reported-by: Tom Gundersen <teg@jklm.no>
> 
> Thanks. That looks correct to me (not able to test at the moment
> though). Would this be appropriate for stable if it goes in?

This can apply 3.14 as is.
For 3.12 or earlier tree, this needs modification to insert the fdb
entry (or backport fdb fix patchset (684bd2e1)).
And for 3.2, another patch needs to be backported before this because
br_fdb_change_mac_address() doesn't exist.

Thanks,
Toshiaki Makita
