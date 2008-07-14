From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: TAP (and TUN?) devices not working after resume
Date: Mon, 14 Jul 2008 09:31:01 -0700
Message-ID: <2c0942db0807140931j53d53bb8oae4f1b442fbc7018@mail.gmail.com>
References: <20080714154720.791f6640@symphony> <200807141812.45264.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: suspend-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <suspend-devel-bounces@lists.sourceforge.net>
In-Reply-To: <200807141812.45264.rjw@sisk.pl>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/suspend-devel>,
	<mailto:suspend-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=suspend-devel>
List-Post: <mailto:suspend-devel@lists.sourceforge.net>
List-Help: <mailto:suspend-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/suspend-devel>,
	<mailto:suspend-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: suspend-devel-bounces@lists.sourceforge.net
Errors-To: suspend-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Jul 14, 2008 at 9:12 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Monday, 14 of July 2008, James Le Cuirot wrote:
>> uswsusp works great on my machine except for one thing. I use a TAP
>> device for QEMU and after resuming from suspend, it doesn't work
>> anymore until I delete it and recreate it. This is rather annoying
>> because if I have QEMU open, it means I have to close it before
>> recreating the interface and then boot Windows up again. I use OpenVPN
>> to create/delete the interface but I think that's all it does. The rest
>> is done by the kernel. So I'm guessing something's up with the TUN/TAP
>> driver or uswsusp itself. I'm using version 0.8. Sorry if this has
>> already been fixed.
>
> This is a kernel problem, adding kernel-related CCs.

Oh, hmm. I noticed this about a year ago after a kernel upgrade, and
threw the below into /etc/acpi/resume.d/91-openvpn.sh to fix the issue
on resume. It was supposed to be temporary until I could track down
whether this was a kernel issue or whatnot, but then I sorta, uhm,
forgot to report it. But yeah, I see the same issue -- after resume,
the TUN device has disappeared, and openvpn needs to be told to close
and reopen for it to work again.

#!/bin/sh
# poke openvpn to rebuild the tunnel
if pidof openvpn > /dev/null; then
	killall -SIGHUP openvpn
fi

-------------------------------------------------------------------------
Sponsored by: SourceForge.net Community Choice Awards: VOTE NOW!
Studies have shown that voting for your favorite open source project,
along with a healthy diet, reduces your potential for chronic lameness
and boredom. Vote Now at http://www.sourceforge.net/community/cca08
