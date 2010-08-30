From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH] e1000e: Intel 82571EB: Don't wait for MNG
 cycle on unmanaged chips
Date: Mon, 30 Aug 2010 13:49:29 -0700
Message-ID: <AANLkTin69t9Z4vunB4t4X6p77=QSR9m+JueCcKSm8jEL@mail.gmail.com>
References: <1282936206-17288-1-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Kyle Moffett <kyle@moffetthome.net>, linux-kernel@vger.kernel.org
To: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1282936206-17288-1-git-send-email-Kyle.D.Moffett@boeing.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, Aug 27, 2010 at 12:10 PM, Kyle Moffett
<Kyle.D.Moffett@boeing.com> wrote:
> The Intel 82571EB chipset can be used in an unmanaged configuration as a
> fast dual-port Gig-E controller. =A0Unfortunately a board constructed that
> way would fail to correctly come up because the driver polls for the
> completion of a management cycle that will never occur.
>
> To resolve this problem, we disable the poll and error return on chips
> whose EEPROMs indicate no management. =A0As a protection against
> misconfigured chipsets, we still delay for the entire management poll
> timeout.
>
> Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>

Hi Kyle, thanks for submitting this patch.  Are you fixing this
problem for a device that is a LOM?  The reason I ask is that most if
not all of our current eeprom images require some firmware interaction
to correctly initialize the PHY when the part is reset, even for the
no_mng (no managability) case.

Your code below will avoid reading of and waiting for the cfg_done
bit, which means that the firmware could end up racing with the
driver, with them both trying to configure the part.

Was there a specific bug you were trying to fix, and can you reply (if
you want to me in private) with your ethtool -e ethX output?

The concern here is that you may simply have an out of date eeprom
image, which might fix the original issue and get the driver to work
correctly, as the behavior you are describing is not how it should
work according to our design.

At the very least we would like to reproduce your issue here so we can
investigate further.

Jesse

---------------------------------------------------------------------------=
---
This SF.net Dev2Dev email is sponsored by:

Show off your parallel programming skills.
Enter the Intel(R) Threading Challenge 2010.
http://p.sf.net/sfu/intel-thread-sfd
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
