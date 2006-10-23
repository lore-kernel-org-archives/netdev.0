From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Mon, 23 Oct 2006 08:29:31 -0700
Message-ID: <20061023152931.GB22485@devicescape.com>
References: <1161335976.21402.11.camel@devlinux-hong> <20061023144028.629dc5d8@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hong Liu <hong.liu@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:37061 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S964939AbWJWP3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 11:29:43 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061023144028.629dc5d8@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 23, 2006 at 02:40:28PM +0200, Jiri Benc wrote:
> On Fri, 20 Oct 2006 17:19:36 +0800, Hong Liu wrote:
> > --- a/include/net/d80211.h
> > +++ b/include/net/d80211.h
> > @@ -176,6 +176,7 @@ struct ieee80211_tx_control {
> >  			*/
> >  	int icv_len:8; /* Length of the ICV/MIC field in octets */
> >  	int iv_len:8; /* Length of the IV field in octets */
> > +	u8 rc4key[16]; /* generated RC4 key for hw TKIP */
> 
> I don't like extending ieee80211_tx_control by 16 more bytes. The
> driver is required to store a copy of each ieee80211_tx_control
> (because it's copied to ieee80211_tx_status). I don't have a better
> idea, though. Anybody?

We could be more selective about what the driver is required to return
in ieee80211_tx_status, the rc4key isn't particularily interesting to
ieee80211_tx_status().  I expect there are other uninteresting fields
(tx_rate, rts_cts_rate, come to mind, for example).  We could put the
fields we are interested in directly in ieee80211_tx_status, or have a
new structure rather than re-using ieee80211_tx_control inside
ieee80211_tx_status.

-David
