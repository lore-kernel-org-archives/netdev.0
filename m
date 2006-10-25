From: Dan Williams <dcbw@redhat.com>
Subject: RE: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Wed, 25 Oct 2006 01:03:47 -0400
Message-ID: <1161752627.23364.14.camel@localhost.localdomain>
References: <C86180A8C204554D8A3323D8F6B0A29F018523F7@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50366 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1422992AbWJYFEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 01:04:06 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018523F7@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-24 at 15:56 -0700, Simon Barber wrote:
> Hi Luis,
> 
> The CVS version of wpa_supplicant implements a user space Client MLME.
> 
> Are there any FullMAC clients that do not also do regulatory in the
> hardware? (Intel 2100/2200?)

Atmel (atmel.c) has in-driver regulatory domain logic, though it uses a
firmware default domain.  But that can be overridden by the user, and it
appears as if the firmware just accepts it.

Orinoco, Airo, Prism54 (fullmac) all have a channel list in the driver
for validation, though the firmware on both appears to enforce
regulatory domains and the drivers return errors or the firmware refuses
to associate when given channels outside the current regulatory domain.

In short, it would be nice to have a common table of regulatory domain
information (at least channel #s, frequency #s, and regulatory domain
lookup tables) somewhere in the ieee80211 stack where even fullmac
drivers could get to it, if just to reduce code duplication.

Dan

> 
> Simon
>  
> 
> -----Original Message-----
> From: Luis R. Rodriguez [mailto:mcgrof@gmail.com] 
> Sent: Tuesday, October 24, 2006 3:03 PM
> To: Simon Barber
> Cc: David Kimdon; netdev@vger.kernel.org; Jiri Benc; John W. Linville;
> Jean Tourrilhes
> Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
> 
> On 10/24/06, Simon Barber <simon@devicescape.com> wrote:
> > The Client MLME code in the kernel was only ever written to be used 
> > for quick testing. It does not have good roaming performance, and was 
> > never intended to be a complete client. The right place for the Client
> 
> > MLME is in userspace, where it can be closely coupled with the 
> > supplicant, and better scanning and roaming decisions can be made. If 
> > the Client MLME is removed from the kernel, then a userspace part is 
> > always required in order for 802.11 to be used at all. (It's already 
> > required in order to use any of the recent security modes, or have 
> > automatic network selection, or decent roaming). In this case the 
> > regulatory constraints can be set in a privileged userspace deamon.
> 
> We also have to take into consideration FullMAC devices where we don't
> need an MLME implemented in kernel/userspace and how regulatory domain
> control will dictate their behaviour. My approach here was to support a
> map between stack regulatory domain values and device regulatory domain
> values. This is currently provided by ieee80211_regdomains. We can add
> to ieee80211_conf a ieee80211_regulatory_map and if defined
> d80211 will simply call the the stack's set regdomain which the device
> implements and sets the regdomain internally to whatever the device
> should have.
> 
> Mind you I realize most new devices are taking the SoftMAC design
> approach and while these vary ultimately I do agree with your point.
> 
> All that said though:
> 
> 1. Anyone working on completing FullMAC support on d80211?
> 2. Who's working on a userspace MLME replacement for d80211 and where
> are we with that?
> 3. Who's doing the endianness/smp testing of d80211 and how far are we
> with that?
> 
> Lastly, as I have said in previous e-mails -- I agree with a userspace
> daemon but where is it and how long before its ready.. also it may be
> difficult to introduce as a requirement for distributions and for this
> reason I am suggesting going with in-kernel regulatory domain control
> and now perhaps in-kernel MLME for a first stable push of d80211,
> specially since only... 3 in-kernel drivers currently use d80211!
> 
>   Luis
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

