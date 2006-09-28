From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: softmac mtu
Date: Thu, 28 Sep 2006 17:47:12 +0200
Message-ID: <1159458432.2648.38.camel@ux156>
References: <ef3s4u$or5$3@sea.gmane.org>
	 <1159365434.451a833ae7728@imp3-g19.free.fr>
	 <1159365316.2698.40.camel@ux156>  <200609281735.17616.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, castet.matthieu@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35267 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964948AbWI1Pqb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 11:46:31 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609281735.17616.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 17:35 +0200, Michael Buesch wrote:

> I am pretty sure this is the maximum _fragment_ size.

But then why does it talk of MPDU and MSDU?

from 802.11:

synonym sMaxMsduLng Integer = 2304; /* max octets in an MSDU */

synonym sMaxMpduLng Integer =         /* max octets in an MPDU */
  (sMaxMsduLng + sMacHdrLng + sWdsAddLng + sWepAddLng + sCrcLng);

synonym sMinFragLng Integer = 256; /* min value for aMpduMaxLength */
synonym sMaxFragNum Integer =        /* maximum fragment number */
  (sMaxMsduLng / (sMinFragLng - sMacHdrLng - sCrcLng));

The last calculation implies that each frame can only be up to
sMaxMsduLng octets long even when fragmented.

also cf. 9.1.4:

   9.1.4 Fragmentation/defragmentation overview

   The process of partitioning a MAC service data unit (MSDU) or a MAC
   management protocol data unit (MMPDU) into smaller MAC level frames,
   MAC protocol data units (MPDUs), is called fragmentation.
   Fragmentation creates MPDUs smaller than the original MSDU or MMPDU
   length to increase reliability, by increasing the probability of
   successful transmission of the MSDU or MMPDU in cases where channel
   characteristics limit reception reliability for longer frames.

IOW, I read it as an MSDU is the data that is supposed to be transmitted
over the link and that can be at most 2304 bytes long, and then it may
be fragmented or not and is then copied into (an) MPDU(s).

> But each packet (which max size is defined by the MTU) can
> be fragmented. I don't know if there's a limit on the max
> number of frags.

There's only a 4 bit fragment counter ;) However, see above.

johannes
