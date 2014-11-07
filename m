From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [linux-nics] [PATCH net 3/5] fm10k: Implement ndo_gso_check()
Date: Fri, 7 Nov 2014 17:51:32 +1300
Message-ID: <201411071751.33390.joestringer@nicira.com>
References: <1415138202-1197-1-git-send-email-joestringer@nicira.com> <20141107003821.GA10692@gmail.com> <D0815B72.5EAF9%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"shahed.shaikh" <shahed.shaikh@qlogic.com>,
	"sathya.perla" <sathya.perla@emulex.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Vadai <amirv@mellanox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	"dept-gelinuxnicdev" <Dept-GELinuxNICDev@qlogic.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"Amir@isotope.jf.intel.com" <Amir@isotope.jf.intel.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:33643 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751426AbaKGEvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 23:51:44 -0500
Received: by mail-pd0-f180.google.com with SMTP id ft15so2545785pdb.25
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 20:51:43 -0800 (PST)
In-Reply-To: <D0815B72.5EAF9%matthew.vick@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Nov 2014 14:20:08 Vick, Matthew wrote:
> On 11/6/14, 4:55 PM, "Joe Stringer" <joestringer@nicira.com> wrote:
> >On Thu, Nov 06, 2014 at 11:58:32PM +0000, Vick, Matthew wrote:
> >> On 11/5/14, 11:36 AM, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
> >>
> >>wrote:
> >> Hi Joe, fm10k's hardware is pretty lax about the header size. As long as
> >> the total header length (outer+inner) is 184 bytes or less we're golden,
> >> so if I'm not mistaken that leaves us with a max of 130 bytes beyond the
> >> tunnel header.
> >
> >Oh, okay. To be more explicit, in the case of UDP tunnels I take it that
> >you're talking about L2+L3+(L4+)tunnel+L2+L3+L4 <= 184? (L4 perhaps
> >optional depending on the tunnel protocol used)
> >
> >In that case, the fm10k_gso_check would use something closer to
> >"skb_inner_transport_header(skb) - skb_mac_header(skb) > 184", or
> >perhaps 164 to allow for inner L4 header (?).
> >
> >Joe
> 
> Yes, I'm talking about the full shebang.
> 
> I like the 164 check, personally (with appropriate #define for
> readability).

Thanks for the feedback, I take it that this approach is preferable over the 
other one involving an skb_gso_check() + fm10k_tx_encap_offload() call?
