From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Wed, 1 Oct 2003 11:49:04 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310011149.04612.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A464F2@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, "Chad N. Tindel" <chad@tindel.net>,
        <fubar@us.ibm.com>, <jgarzik@pobox.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A464F2@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 01 October 2003 10:05 am, David S. Miller wrote:
> On Tue, 30 Sep 2003 17:36:50 -0400
>
> "Chad N. Tindel" <chad@tindel.net> wrote:
> > My recommendations are more towards the middle than either end. 
> > I would like to see us get rid of the _OLD ioctls in the 2.6
> > kernel specifically because it uses the SIOCDEVPRIVATE ioctls.
>
>  ...
>
> > I would like to see them stay in 2.4 for the rest of the 2.4 tree
> > specifically so that people who want to run on 3 year old systems
> > can continue to do so without us breaking their world.
>
> I think this is fine, personally.
>
> I defer to Jeff for final judgment, he should be allowed to chime
> in at least once more.
>

So here is what I did in the meantime:
* Created a version for 2.4 that puts back all old compatibility stuff 
  that was removed either during the propagation set or the cleanup 
  set.
* Created a version for 2.6 that puts back just the compatibility 
  stuff that was removed in the propagation set (BOND_SETHWADDR, since 
  we got a complaint from a RH9 user).
* Removed the mention of the multicast param from the read-me.
* Raised the ABI version to 2 so the new ifenslave keeps propagating 
  IP settings to slaves for older drivers, and doesn't do that for new 
  ones that contain Willy Tarreau's panic fix.

As for not putting new stuff in 2.4.x kernels, here is where we stand;
We believe new distributions based on 2.4.x kernels will keep showing 
for at least a year, probably longer, and that customers would like 
to see more bonding features in those distributions, so our intention 
is to keep getting new stuff into 2.4. We understand the drive to put 
new stuff into 2.6 and backport to 2.4 from time to time, but we'll 
really need to keep doing stuff the current way for a while.

The cleanup stuff came up as a necessity before developing the next 
set of features, and those are all based on a cleaned-up bonding, so 
delaying the acceptance of the cleanup into 2.4 also delays our 
features acceptance.

I'm waiting for the final word from everyone. I'll need to test the 
two new versions, but then I can release them accordingly.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
