From: Willy TARREAU <willy@w.ods.org>
Subject: Re: [Bonding-announce] [PATCH SET][bonding] cleanup
Date: Mon, 6 Oct 2003 00:28:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005222817.GA2527@pcw.home.local>
References: <shmulik.hen@intel.com> <200309252011.53960.shmulik.hen@intel.com> <200309251733.h8PHXWpV013559@death.ibm.com> <20030925211259.GA59653@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>, shmulik.hen@intel.com,
        "Chad N. Tindel" <chad@tindel.net>,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        Jeff Garzik <jgarzik@pobox.com>, "Noam, Amir" <amir.noam@intel.com>,
        "Mendelson, Tsippy" <tsippy.mendelson@intel.com>,
        "Noam, Marom" <noam.marom@intel.com>
Content-Disposition: inline
In-Reply-To: <20030925211259.GA59653@calma.pair.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi !

On Thu, Sep 25, 2003 at 05:13:00PM -0400, Chad N. Tindel wrote:
 
> I was specifically told by David Miller that we are not to break binary
> compatibility within a 2.4 release.  Such things had to wait until 2.5 
> or later.  We can not require a user to upgrade their ifenslave within a 2.4
> series kernel just to keep using the same functionality they were using in 
> 2.4.1.

I strongly agree. I have been facing this problem and it was really a pain. I
used the last bonding version which didn't define the ABI version, together
with the associated ifenslave, but when the need to upgrade to plain 2.4.22
came in, I had the surprize of getting a non-working bonding because this
intermediate ifenslave. Well, I upgraded it to latest version, which prevents
me from downgrading to the previous kernel because it has ABIv2 with no version,
so the newer ifenslave thinks it's an ABIv1. So the result is a symlink with
two versions of ifenslave on the disk, just in case I have to downgrade.

Although I agree it's clearly my fault and I should have been more careful, I
prefer to warn everyone about the consequences this might have on production
systems. Schmulik has done quite a great job here, and I believe most of it
should be integrated, but we have to carefully test each combination of old/new
ifenslave with old/new driver if we don't want to break some setups or prevent
admins from downgrading if something goes wrong.

Cheers,
Willy
