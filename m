From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Prism54 WPA Support - wpa_supplicant - Linux general wpa support
Date: Fri, 4 Jun 2004 11:01:06 -0700
Sender: prism54-devel-admin@prism54.org
Message-ID: <20040604180106.GA19181@bougret.hpl.hp.com>
References: <20040602071449.GJ10723@ruslug.rutgers.edu> <20040602132313.GB7341@jm.kir.nu> <20040602155542.GC24822@ruslug.rutgers.edu> <20040603165233.GC8770@bougret.hpl.hp.com> <20040604023303.GB7537@jm.kir.nu>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <prism54-devel-admin@prism54.org>
To: Netdev <netdev@oss.sgi.com>, hostap@shmoo.com,
	prism54-devel@prism54.org, Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20040604023303.GB7537@jm.kir.nu>
Errors-To: prism54-devel-admin@prism54.org
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Post: <mailto:prism54-devel@prism54.org>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel/>
List-Id: netdev.vger.kernel.org

On Thu, Jun 03, 2004 at 07:33:03PM -0700, Jouni Malinen wrote:
> On Thu, Jun 03, 2004 at 09:52:33AM -0700, Jean Tourrilhes wrote:
> 
> > 	So, the plan would be to take Jouni's API as is (or with minor
> > modifications) and stuff that in wireless.h. I don't believe that the
> > tools themselves need to be modified, because wpa_supplicant is the
> > sole user of those ioctls.
> > 	If you are all happy with that, then I'll just do it.
> 
> I'm mostly happy with this, but this should also include something from
> the private ioctls hostapd uses for AP functionality.

	Obviously we need the full functionality, not just some part
of it.

> In addition, I would consider changing couple of text based elements
> (e.g., WPA IE as hex string) to binary in order to remove extra
> parsing code and make the data contents smaller.

	The downside of that is that things need to be predefined. As
we are doing a "WPA API" and not a "generic link layer security API",
that's OK.
	The other thing you may want to think about is miving all
string/arrays at the end of the definition so that we can grow them
easily if needed, and so that the first part can be fixed.

> I'm having quite a bit of problems with scan
> results getting too large for the current limit of 4 kB.. Admittedly,
> this is in a test lab environment, but still, it is annoying and
> requires workarounds like driver side filtering of the scan results.

	That's easy to fix. I did the same with "iwpriv" definitions a
couple of weeks ago. Basically, you return -E2BIG to user space until
userspace give you a big enough buffer.
	I'll try to fix that.

> I could try to make a list of all private ioctls currently used in
> wpa_supplicant and hostapd, including some comments on what I would
> consider changing at this point (mostly, changing text binary for couple
> of cases and removing some fields that are not really going to be used).

	You currently have your plate pretty full. I'll try to help,
but my first son was born one month ago and things are not as smooth
as planned.

> Jouni Malinen

	Jean
